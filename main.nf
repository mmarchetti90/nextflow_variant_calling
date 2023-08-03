#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
Variant calling of short reads sequencing samples
*/

// ----------------Workflow---------------- //

include { TrimFastQ } from './modules/trimgalore.nf'
include { MapReads_BWA } from './modules/map_reads_bwa.nf'
include { MapReads_Bowtie } from './modules/map_reads_bowtie.nf'
include { GATK } from './workflows/gatk_calling.nf'
include { LOFREQ } from './workflows/lofreq_calling.nf'

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

  // TRIMGALORE --------------------------- //

  // Run TrimGalore
  TrimFastQ(raw_reads)

  // Merge trimmed_fastq_files and reference_fasta channels
  TrimFastQ.out.trimmed_fastq_files
  .join(reference_fasta, by: 0, remainder: false)
  .set{mapping_inputs}

  // MAPPING READS ------------------------ //

  if (params.mapper == "bwa") {

    // MAPPING READS WITH BWA --------------- //

    MapReads_BWA(mapping_inputs)

    bam_files = MapReads_BWA.out.bam_files

  }
  else {

    // MAPPING READS WITH BOWTIE2 ----------- //

    MapReads_Bowtie(mapping_inputs)

    bam_files = MapReads_Bowtie.out.bam_files

  }

  // VARIANT CALLING ---------------------- //

  // GATK variant calling and consensus fasta generation
  GATK(bam_files)
  
  // LoFreq variant calling and consensus fasta generation

  if (params.run_lofreq == true) {

    LOFREQ(bam_files)

  }

}