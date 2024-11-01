process IndexFastaBowtie {

  // Index reference fasta
  
  label 'mapping'

  input:
  tuple val(sample_id), path(reference_fasta)

  output:
  tuple val(sample_id), path("*.bt2"), emit: bowtie_index

  """
  # Generate Bowtie2 index
  bowtie2-build ${reference_fasta} b2_index
  """

}
