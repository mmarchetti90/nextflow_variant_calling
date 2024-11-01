
// ----------------Workflow---------------- //

include { MakeGATKDict } from '../../modules/single_calling/indexing/make_gatk_dict.nf'
include { VariantsGATK } from '../../modules/single_calling/var_calling/variants_gatk.nf'
include { FilterVCF } from '../../modules/common/var_calling/filter_vcf.nf'
include { IndexVcfTabix } from '../../modules/common/indexing/index_vcf_tabix.nf'
include { ConvertVCF } from '../../modules/single_calling/vcf2fasta/vcf2fasta.nf'

workflow GATK {

  take:
  bam_files
  bam_index
  reference_fasta
  reference_fasta_index
  low_coverage_mask
	
  main:
  // GATK VARIANT CALLER ------------------ //

  // Create GATK dictionary
  MakeGATKDict(reference_fasta)

  // Prep input
  bam_files
  .join(bam_index, by: 0, remainder: false)
  .join(reference_fasta, by: 0, remainder: false)
  .join(reference_fasta_index, by: 0, remainder: false)
  .join(MakeGATKDict.out.gatk_dict, by: 0, remainder: false)
  .set{gatk_input}

  // GATK
  VariantsGATK(gatk_input)

  // Filtering
  FilterVCF(VariantsGATK.out.gatk_vcf_unfilt)

  // CONVERTING VCF TO FASTA -------------- //

  // Index vcf
  IndexVcfTabix(FilterVCF.out.gatk_vcf_filt)

  // Join VariantsGATK.out.gatk_vcf_filt and low_coverage mask
  FilterVCF.out.gatk_vcf_filt
  .join(IndexVcfTabix.out.vcf_index, by: 0, remainder: false)
  .join(reference_fasta, by: 0, remainder: false)
  .join(reference_fasta_index, by: 0, remainder: false)
  .join(low_coverage_mask, by: 0, remainder: false)
  .set{vcf_to_fasta_input}

  // Convert vcf to fasta
  ConvertVCF("gatk", vcf_to_fasta_input)

}
