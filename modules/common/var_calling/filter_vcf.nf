process FilterVCF {

  // Filtering VCF file
  
  label 'variantcalling'

  publishDir "${projectDir}/${sample_id}/${params.variants_out}", mode: "copy", pattern: "*_gatk_filt.vcf.gz"

  input:
  tuple val(sample_id), path(vcf)

  output:
  tuple val(sample_id), path("${sample_id}_gatk_filt.vcf.gz"), emit: gatk_vcf_filt

  """
  # Use bcftools to filter - can only apply one expression at a time.
  bcftools filter --soft-filter 'lowQual' --exclude '(QUAL < ${params.qual_threshold} && QUAL != ".") || RGQ < ${params.qual_threshold}' ${vcf} | \
  bcftools filter --soft-filter 'lowDepth' --exclude 'FORMAT/DP < ${params.depth_threshold}' -O z -o ${sample_id}_gatk_filt.vcf.gz
  """

}