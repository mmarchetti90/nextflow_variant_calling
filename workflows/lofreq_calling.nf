
// ----------------Workflow---------------- //

include { VariantsLoFreq } from '../modules/variants_lofreq.nf'
include { ConvertVCF } from '../modules/vcf2fasta.nf'

workflow LOFREQ {

  take:
  bam_files
	
  main:
  // LOFREQ VARIANT CALLER ---------------- //

  VariantsLoFreq(bam_files)

  // CONVERTING VCF TO FASTA -------------- //

  // Not working well, would have to modify header
  //ConvertVCF("lofreq", VariantsLoFreq.out.lofreq_vcf_filt)

}
