process Minimap2 {

  // Map reads

  label 'ont'

  input:
  each path(reference_fasta)
  tuple val(sample_id), path(ont_reads)

  output:
  tuple val("${sample_id}"), path("temp.sam"), optional: false, emit: aligned_ont

  """
  # Minimap2 alignment
  temp="${ont_reads}"

  if [[ \${temp: -3} == "bam" ]]
  then

    # Convert input bam to fastq, then align with Minimap2
    samtools fastq \
    ${ont_reads} | \
    minimap2 \
    ${params.minimap2_parameters} \
    -t \$SLURM_CPUS_ON_NODE \
    -ax map-ont \
    ${reference_fasta} \
    - \
    -y | \
    samtools view \
    -h \
    -o temp.sam

  else

    minimap2 \
    ${params.minimap2_parameters} \
    -t \$SLURM_CPUS_ON_NODE \
    -ax map-ont \
    ${reference_fasta} \
    ${ont_reads} \
    -y | \
    samtools view \
    -h \
    -o temp.sam

  fi
  """

}