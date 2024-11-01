#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
Variant calling of short reads sequencing samples
*/

// ----------------Workflow---------------- //

include { SINGLECALLING } from './workflows/single_calling.nf'
include { JOINTCALLING } from './workflows/joint_calling.nf'

workflow {

  if (params.single_calling == true) {
    
    SINGLECALLING()

  }
  else if (params.single_calling == false) {
    
    JOINTCALLING()

  } else {

    println "ERROR: Unrecognized profile!"
    println "Please chose one of: standard, gene_lvl, transcript_lvl, cellranger, small_rna, mirna"

  }

}