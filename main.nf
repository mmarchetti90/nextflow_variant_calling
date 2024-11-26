#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
Variant calling of short reads sequencing samples
*/

// ----------------Workflow---------------- //

include { SINGLECALLING_SHORT } from './workflows/single_calling_short.nf'
include { JOINTCALLING_SHORT } from './workflows/joint_calling_short.nf'
include { JOINTCALLING_ONT } from './workflows/joint_calling_ont.nf'

workflow {

  if (params.single_calling == true) {
    
    SINGLECALLING_SHORT()

  }
  else if (params.single_calling == false) {
    
    JOINTCALLING_ONT()

  }
  else if (params.single_calling == false) {
    
    JOINTCALLING_SHORT()

  } else {

    println "ERROR: Unrecognized profile!"
    println "Please chose one of: single, joint"

  }

}