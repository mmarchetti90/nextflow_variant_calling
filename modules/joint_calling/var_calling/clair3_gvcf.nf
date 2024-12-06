process Clair3GVCF {

  // Variant calling with Clair3
  
  label 'clair3'

  publishDir "${projectDir}/${sample_id}/${params.variants_out}", mode: "copy", pattern: "*_clair3.g.vcf.gz"

  input:
  each path(reference_fasta)
  each path(reference_index)
  tuple val(sample_id), path(bam), path(bam_index)

  output:
  tuple val(sample_id), path("${sample_id}_clair3_pilup.vcf.gz"), emit: clair3_pileup
  tuple val(sample_id), path("${sample_id}_full_alignment.vcf.gz"), emit: clair3_alignment
  tuple val(sample_id), path("${sample_id}_clair3.vcf.gz"), emit: clair3_vcf
  tuple val(sample_id), path("${sample_id}_clair3.g.vcf.gz"), emit: clair3_gvcf

  """
  if [[ "${params.ploidy}" == "1" ]]
  then

    phasing="--no_phasing_for_fa"

  else

    phasing=""

  fi

  /opt/bin/run_clair3.sh \
  --bam_fn=${bam} \
  --ref_fn=${reference_fasta} \
  --threads=\$SLURM_CPUS_ON_NODE \
  --gvcf \
  --include_all_ctgs \
  --qual=${params.qual_threshold} \
  --sample_name=${sample_id} \
  \$phasing \
  --platform="ont" \
  --model_path="/opt/models/${params.clair3_model}" \
  --output=\$(pwd)

  mv pileup.vcf.gz ${sample_id}_clair3_pilup.vcf.gz
  mv full_alignment.vcf.gz ${sample_id}_full_alignment.vcf.gz
  mv merge_output.vcf.gz ${sample_id}_clair3.vcf.gz
  mv merge_output.gvcf.gz ${sample_id}_clair3.g.vcf.gz
  """

}
