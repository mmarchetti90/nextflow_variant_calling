process ConvertVCF {

  // Convert single sample VCF to fasta

  label 'variantcalling'

  publishDir "${projectDir}/${sample_id}/${params.fasta_out}", mode: "copy", pattern: "*.fa"

  input:
  each variant_caller
  tuple val(sample_id), path(vcf), path(vcf_index), path(reference_fasta), path(reference_index), path(low_coverage_mask), path(low_coverage_mask_index)

  output:
  tuple val(sample_id), path("${sample_id}_${variant_caller}.fa"), emit: fasta_files

  """
  # N.B. The vcf files come from individual samples, so no need to specify --sample in bcftools consensus (also, LoFreq does not store sample name info in the vcf)

  if [ ${params.variants_only} == false ]
  then 
  
    # Consensus with quality filters applied (exclude indels). Positions absent from VCF will be included as consensus
    #bcftools consensus --include "(TYPE!='indel') && (QUAL >= ${params.qual_threshold} || RGQ >= ${params.qual_threshold})" --mask ${low_coverage_mask} --fasta-ref ${reference_fasta} --missing 'N' --absent 'N' ${vcf} > ${sample_id}_${variant_caller}_no_indels.fa

    # Consensus with quality filters applied (with indels). Positions absent from VCF will be included as consensus
    bcftools consensus --include "(QUAL >= ${params.qual_threshold} || RGQ >= ${params.qual_threshold})" --mask ${low_coverage_mask} --fasta-ref ${reference_fasta} --missing 'N' --absent 'N' ${vcf} > ${sample_id}_${variant_caller}.fa
  
  else
  
    # Consensus with quality filters applied (exclude indels)
    #bcftools consensus --include "(TYPE!='indel') && (QUAL >= ${params.qual_threshold} || RGQ >= ${params.qual_threshold})" --mask ${low_coverage_mask} --fasta-ref ${reference_fasta} --missing 'N' ${vcf} > ${sample_id}_${variant_caller}_no_indels.fa

    # Consensus with quality filters applied (with indels)
    bcftools consensus --include "(QUAL >= ${params.qual_threshold} || RGQ >= ${params.qual_threshold})" --mask ${low_coverage_mask} --fasta-ref ${reference_fasta} --missing 'N' ${vcf} > ${sample_id}_${variant_caller}.fa
  
  fi
  """

}
