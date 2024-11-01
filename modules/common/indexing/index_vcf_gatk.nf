process IndexVcfGATK {

  // Indexing vcf file
  
  label 'variantcalling'

  input:
  tuple val(sample_id), path(vcf)

  output:
  tuple val(sample_id), path("*.tbi"), emit: vcf_index

  """
  # Index vcf
  gatk IndexFeatureFile -I ${vcf}
  """

}
