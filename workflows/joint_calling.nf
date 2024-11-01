#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
Variant calling of short reads sequencing samples
*/

// ----------------Workflow---------------- //

include { IndexFastaSamtools } from '../modules/joint_calling/indexing/index_fasta_samtools.nf'
include { MakeGATKDict } from '../modules/joint_calling/indexing/make_gatk_dict.nf'
include { TrimFastQ } from '../modules/common/trimming/trimgalore.nf'
include { MapReads_BWA } from '../modules/joint_calling/mapping/map_reads_bwa.nf'
include { MapReads_Bowtie } from '../modules/joint_calling/mapping/map_reads_bowtie.nf'
include { IndexBam } from '../modules/common/indexing/index_bam.nf'
include { GATK } from '../subworkflows/joint_calling/gatk_calling.nf'
include { LOFREQ } from '../subworkflows/joint_calling/lofreq_calling.nf'

workflow {

  // CREATING INPUT CHANNELS -------------- //

  // Reads channel
  Channel
  .fromPath("${params.data_manifest_path}")
  .splitCsv(header: true, sep: '\t')
  .map{row -> tuple(row.SampleID, file(row.ShortReads_Mate1), file(row.ShortReads_Mate2))}
  .set{raw_reads}

  // Reference fasta channel
  Channel
  .fromPath("${params.reference_fasta}")
  .set{reference_fasta}

  // Index fasta
  IndexFasta(reference_fasta)

  // TRIMGALORE --------------------------- //

  // Run TrimGalore
  TrimFastQ(raw_reads)

  // MAPPING READS ------------------------ //

  if (params.mapper == "bwa") {

    // MAPPING READS WITH BWA --------------- //

    // Index reference
    IndexFastaBwa(reference_fasta)

    // Map
    MapReads_BWA(reference_fasta, IndexFastaBwa.out.bwa_index, TrimFastQ.out.trimmed_fastq_files)

    bam_files = MapReads_BWA.out.bam_files

  }
  else {

    // MAPPING READS WITH BOWTIE2 ----------- //

    // Index reference
    IndexFastaBowtie(reference_fasta)

    // Map
    MapReads_Bowtie(reference_fasta, IndexFastaBwa.out.bwa_index, TrimFastQ.out.trimmed_fastq_files)

    bam_files = MapReads_Bowtie.out.bam_files

  }

  // Indexing bam
  IndexBam(bam_files)

  // VARIANT CALLING ---------------------- //

  // GATK variant calling
  GATK(bam_files, IndexBam.out.bam_index, reference_fasta, IndexFastaSamtools.out.reference_fasta_index)

}