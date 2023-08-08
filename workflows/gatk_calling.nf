
// ----------------Workflow---------------- //

include { VariantsGATK } from '../modules/variants_gatk.nf'
include { ConvertVCF } from '../modules/vcf2fasta.nf'

workflow GATK {

  take:
  bam_files
  low_coverage_mask
	
  main:
  // GATK VARIANT CALLER ------------------ //

  VariantsGATK(bam_files)

  // CONVERTING VCF TO FASTA -------------- //

  // Join VariantsGATK.out.gatk_vcf_filt and low_coverage mask
  VariantsGATK.out.gatk_vcf_filt
  .join(low_coverage_mask, by: 0, remainder: false)
  .set{vcf_to_fasta_input}

  // Convert vcf to fasta
  ConvertVCF("gatk", vcf_to_fasta_input)

}
