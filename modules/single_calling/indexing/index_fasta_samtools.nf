process IndexFastaSamtools {

  // Index reference fasta
  
  label 'variantcalling'

  input:
  tuple val(sample_id), path(reference_fasta)

  output:
  tuple val(sample_id), path("*.fai"), emit: reference_fasta_index

  """
  # Index reference fasta
  samtools faidx ${reference_fasta}
  """

}
