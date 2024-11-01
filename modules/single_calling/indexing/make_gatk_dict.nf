process MakeGATKDict {

  // Generating GATK dictionary
  
  label 'variantcalling'

  input:
  tuple val(sample_id), path(reference_fasta)

  output:
  tuple val(sample_id), path("*.dict"), emit: gatk_dict

  """
  # Generate GATK dictionary
  gatk CreateSequenceDictionary -R ${reference_fasta}
  """

}
