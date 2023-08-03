process TrimFastQ {

  // Trim reads for quality

  label 'trimgalore'

  //publishDir "${projectDir}/${sample_id}/${params.trimgalore_out}", mode: "copy", pattern: "*_val_{1,2}.fq.gz"
  publishDir "${projectDir}/${sample_id}/${params.reports_out}/trimgalore", mode: "copy", pattern: "*_trimming_report.txt"
  publishDir "${projectDir}/${sample_id}/${params.reports_out}/fastqc", mode: "copy", pattern: "*_fastqc.{html,zip}"

  input:
  tuple val(sample_id), path(read1), path(read2)

  output:
  path "*_fastqc.{html,zip}", emit: fastqc_reports
  path "*_trimming_report.txt", emit: trimming_reports
  tuple val("${sample_id}"), path("{${sample_id}_val_1.fq.gz,${sample_id}_trimmed.fq.gz}"), path("{${sample_id}_val_2.fq.gz,mock.fastq}"), optional: true, emit: trimmed_fastq_files

  """
  if [[ "${read2}" == "mock.fastq" ]]
  then

    trim_galore \
    --cores \$SLURM_CPUS_ON_NODE \
    --output_dir . \
    --basename ${sample_id} \
    --gzip \
    --fastqc \
    ${params.trimgalore_params} \
    ${read1}

    # Adding mock read2 output
    touch mock.fastq

  else

    trim_galore \
    --cores 4 \
    --output_dir . \
    --basename ${sample_id} \
    --gzip \
    --fastqc \
    ${params.trimgalore_params} \
    --paired \
    ${read1} ${read2}

  fi
  """

}