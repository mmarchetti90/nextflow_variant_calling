process Dorado {

  label 'dorado'

  publishDir "${projectDir}/${sample_id}/${params.basecall_out}", mode: "copy", pattern: "*.basecall.bam"
  publishDir "${projectDir}/${sample_id}/${params.bam_out}", mode: "copy", pattern: "*_merged_mrkdup.bam"
  publishDir "${projectDir}/${sample_id}/${params.reports_out}/mapping", mode: "copy", pattern: "*_mapping.log"

  input:
  tuple val(sample_id), path(input_dir)

  output:
  tuple val("${sample_id}"), path("${sample_id}.basecall.bam"), optional: false, emit: basecalled_ont

  """
  # Basecalling
  ${params.dorado_executable_path}dorado basecaller \
  ${params.dorado_model} \
  ${input_dir} \
  --emit-moves \
  ${params.dorado_parameters} > ${sample_id}.basecall.bam
  """

}