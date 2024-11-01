#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
Variant calling of short reads sequencing samples
*/

// ----------------Workflow---------------- //

include { IndexFastaSamtools } from '../modules/single_calling/indexing/index_fasta_samtools.nf'
include { TrimFastQ } from '../modules/common/trimming/trimgalore.nf'
include { MapReads_BWA } from '../modules/single_calling/mapping/map_reads_bwa.nf'
include { IndexFastaBwa } from '../modules/single_calling/indexing/index_fasta_bwa.nf'
include { MapReads_Bowtie } from '../modules/mapping/single_calling/map_reads_bowtie.nf'
include { IndexFastaBowtie } from '../modules/single_calling/indexing/index_fasta_bowtie.nf'
include { IndexBam } from '../modules/common/indexing/index_bam.nf'
include { MakeLowCoverageMask } from '../modules/single_calling/cov_mask/make_low_coverage_mask.nf'
include { GATK } from '../subworkflows/single_calling/gatk_calling.nf'
include { LOFREQ } from '../subworkflows/single_calling/lofreq_calling.nf'

workflow {

  // CREATING CHANNELS FROM MANIFEST ------ //

  // Reads channel
  Channel
  .fromPath("${params.data_manifest_path}")
  .splitCsv(header: true, sep: '\t')
  .map{row -> tuple(row.SampleID, file(row.ShortReads_Mate1), file(row.ShortReads_Mate2))}
  .set{raw_reads}

  // Reference fasta channel
  Channel
  .fromPath("${params.data_manifest_path}")
  .splitCsv(header: true, sep: '\t')
  .map{row -> tuple(row.SampleID, file(row.Reference))}
  .set{reference_fasta}

  // INDEX REFERENCE ---------------------- //

  // Index fasta with samtools
  IndexFastaSamtools(reference_fasta)

  // TRIMGALORE --------------------------- //

  // Run TrimGalore
  TrimFastQ(raw_reads)

  // MAPPING READS ------------------------ //

  if (params.mapper == "bwa") {

    // MAPPING READS WITH BWA --------------- //

    // Index reference
    IndexFastaBwa(reference_fasta)

    // Generate input
    TrimFastQ.out.trimmed_fastq_files
    .join(reference_fasta, by: 0, remainder: false)
    .join(IndexFastaBwa.out.bwa_index, by: 0, remainder: false)
    .set{mapping_inputs}

    // Map
    MapReads_BWA(mapping_inputs)

    bam_files = MapReads_BWA.out.bam_files

  }
  else {

    // MAPPING READS WITH BOWTIE2 ----------- //

    // Index reference
    IndexFastaBowtie(reference_fasta)

    // Generate input
    TrimFastQ.out.trimmed_fastq_files
    .join(reference_fasta, by: 0, remainder: false)
    .join(IndexFastaBwa.out.bowtie_index, by: 0, remainder: false)
    .set{mapping_inputs}

    // Map
    MapReads_Bowtie(mapping_inputs)

    bam_files = MapReads_Bowtie.out.bam_files

  }

  // Indexing bam
  IndexBam(bam_files)

  // VARIANT CALLING ---------------------- //

  // Making a bed mask for low coverage regions
  MakeLowCoverageMask(bam_files)

  // GATK variant calling, consensus fasta generation, and cvs file annotation
  GATK(bam_files, IndexBam.out.bam_index, reference_fasta, IndexFastaSamtools.out.reference_fasta_index, MakeLowCoverageMask.out.low_coverage_mask)
  
  // LoFreq variant calling

  if (params.run_lofreq == true) {

    LOFREQ(bam_files, IndexBam.out.bam_index, reference_fasta, IndexFastaSamtools.out.reference_fasta_index)

  }

}