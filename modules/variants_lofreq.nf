process VariantsLoFreq {

  // Variant calling with LoFreq
  
  label 'variantcalling'

  publishDir "${projectDir}/${sample_id}/${params.variants_out}", mode: "copy", pattern: "*{_lofreq_unfilt,_lofreq_filt}.vcf.gz"

  input:
  tuple val(sample_id), path(bam), path(reference_fasta)

  output:
  tuple val(sample_id), path("${sample_id}_lofreq_unfilt.vcf.gz"), path(reference_fasta), emit: lofreq_vcf_unfilt
  tuple val(sample_id), path("${sample_id}_lofreq_filt.vcf.gz"), path(reference_fasta), emit: lofreq_vcf_filt

  """
  # Index reference fasta
  samtools faidx ${reference_fasta}

  # Index bam
  samtools index ${bam}

  # Call variants with LoFreq, no filter
  lofreq call-parallel \
  --call-indels \
  --pp-threads \$SLURM_CPUS_ON_NODE \
  --no-default-filter \
  -f ${reference_fasta} \
  -o ${sample_id}_lofreq_unfilt.vcf ${bam}

  bgzip ${sample_id}_lofreq_unfilt.vcf

  # Call variants with LoFreq, default filter
  lofreq call-parallel \
  --call-indels \
  --pp-threads \$SLURM_CPUS_ON_NODE \
  -f ${reference_fasta} \
  -o ${sample_id}_lofreq_filt.vcf ${bam}

  bgzip ${sample_id}_lofreq_filt.vcf
  """

}
