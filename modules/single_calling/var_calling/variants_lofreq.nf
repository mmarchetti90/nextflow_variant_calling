process VariantsLoFreq {

  // Variant calling with LoFreq
  
  label 'variantcalling'

  publishDir "${projectDir}/${sample_id}/${params.variants_out}", mode: "copy", pattern: "*{_lofreq_unfilt,_lofreq_filt}.vcf.gz"

  input:
  tuple val(sample_id), path(bam), path(bam_index), path(reference_fasta), path(reference_index)

  output:
  tuple val(sample_id), path("${sample_id}_lofreq_unfilt.vcf.gz"), path(reference_fasta), emit: lofreq_vcf_unfilt
  tuple val(sample_id), path("${sample_id}_lofreq_filt.vcf.gz"), path(reference_fasta), emit: lofreq_vcf_filt

  """
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
