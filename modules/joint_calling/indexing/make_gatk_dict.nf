process MakeGATKDict {

  // Generating GATK dictionary
  
  label 'variantcalling'

  input:
  path reference_fasta

  output:
  path "*.dict", emit: gatk_dict

  """
  # Generate GATK dictionary
  gatk CreateSequenceDictionary -R ${reference_fasta}
  """

}
