
// ----------------Workflow---------------- //

include { MakeGATKDict } from '../../modules/joint_calling/indexing/make_gatk_dict.nf'
include { HaplotypeCaller } from '../../modules/joint_calling/var_calling/haplotype_caller.nf'
include { IndexVcfGATK as IndexSingle } from '../../modules/common/indexing/index_vcf_gatk.nf'
include { CombineGVCFs } from '../../modules/joint_calling/var_calling/combine_gvcf.nf'
include { IndexVcfGATK as IndexCombined } from '../../modules/common/indexing/index_vcf_gatk.nf'
include { GenotypeGVCF } from '../../modules/joint_calling/var_calling/variants_gatk.nf'
include { FilterVCF } from 

workflow GATK {

  take:
  bam_files
  bam_index
  reference_fasta
  reference_fasta_index
	
  main:
  // GATK VARIANT CALLER ------------------ //

  // Create GATK dictionary
  MakeGATKDict(reference_fasta)

  // Prep input for HaplotypeCaller
  bam_files
  .join(bam_index, by: 0, remainder: false)
  .set{bam_input}

  // HaplotypeCaller
  HaplotypeCaller(reference_fasta, reference_fasta_index, MakeGATKDict.out.gatk_dict, bam_input)

  // Index GVCFs
  IndexSingle(HaplotypeCaller.out.gatk_gvcf)

  // Prep input for CombineGVCFs
  HaplotypeCaller.out.gatk_gvcf
  .join(IndexSingle.out.vcf_index, by: 0, remainder: false)
  .collect()
  .set{gvcf_files}

  // CombineGVCFs
  CombineGVCFs(reference_fasta, reference_fasta_index, MakeGATKDict.out.gatk_dict, gvcf_files)

  // Index combined gvcf
  IndexCombined(CombineGVCFs.out.combined_gvcf)

  // Prep input for CombineGVCFs
  CombineGVCFs.out.combined_gvcf
  .join(IndexCombined.out.vcf_index, by: 0, remainder: false)
  .set{indexed_combined_gvcf}

  // Genotyping
  GenotypeGVCF(reference_fasta, reference_fasta_index, MakeGATKDict.out.gatk_dict, indexed_combined_gvcf)

  // Filtering
  FilterVCF(GenotypeGVCF.out.gatk_vcf_unfilt)

}
