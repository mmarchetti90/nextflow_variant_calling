process IndexFastaBwa {

  // Index reference fasta
  
  label 'mapping'

  input:
  path reference_fasta

  output:
  path "*.{rpac,amb,ann,pac,bwt,rbwt,rsa,sa}", emit: bwa_index

  """
  # Generate BWA index
  bwa index ${reference_fasta}
  """

}
