process IndexFastaSamtools {

  // Index reference fasta
  
  label 'variantcalling'

  input:
  path reference_fasta

  output:
  path "*.fai" , emit: reference_fasta_index

  """
  # Index reference fasta
  samtools faidx ${reference_fasta}
  """

}
