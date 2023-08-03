
// ----------------Workflow---------------- //

include { VariantsGATK } from '../modules/variants_gatk.nf'
include { ConvertVCF } from '../modules/vcf2fasta.nf'

workflow GATK {

  take:
  bam_files
	
  main:
  // GATK VARIANT CALLER ------------------ //

  VariantsGATK(bam_files)

  // CONVERTING VCF TO FASTA -------------- //

  ConvertVCF("gatk", VariantsGATK.out.gatk_vcf_filt)

}
