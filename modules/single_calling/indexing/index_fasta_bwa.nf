process IndexFastaBwa {

  // Index reference fasta
  
  label 'mapping'

  input:
  tuple val(sample_id), path(reference_fasta)

  output:
  tuple val(sample_id), path("*.{rpac,amb,ann,pac,bwt,rbwt,rsa,sa}"), emit: bwa_index

  """
  # Generate BWA index
  bwa index ${reference_fasta}
  """

}
