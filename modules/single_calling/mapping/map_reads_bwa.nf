process MapReads_BWA {

  // Map reads and mark duplicates
  
  label 'mapping'

  publishDir "${projectDir}/${sample_id}/${params.bam_out}", mode: "copy", pattern: "*_merged_mrkdup.bam"
  publishDir "${projectDir}/${sample_id}/${params.reports_out}/mapping", mode: "copy", pattern: "*_mapping.log"
  publishDir "${projectDir}/${sample_id}/${params.reports_out}/mapping", mode: "copy", pattern: "*_coverage_stats.txt"
  publishDir "${projectDir}/${sample_id}/${params.reports_out}/mapping", mode: "copy", pattern: "*_marked_dup_metrics.txt"

  input:
  tuple val(sample_id), path(read1), path(read2), path(reference_fasta), path(index)

  output:
  tuple val(sample_id), path("${sample_id}_merged_mrkdup.bam"), emit: bam_files
  path "${sample_id}_mapping.log", emit: mapping_reports
  path "${sample_id}_coverage_stats.txt", emit: coverage_stats
  path "${sample_id}_marked_dup_metrics.txt", emit: dup_metrics

  """
  # Map with BWA
  if [[ "${read2}" == "mock_trim.fastq" ]]
  then

    bwa mem \
    -t \$SLURM_CPUS_ON_NODE \
    ${reference_fasta} \
    ${read1} > temp.sam

  else

    bwa mem \
    -t \$SLURM_CPUS_ON_NODE \
    ${reference_fasta} \
    ${read1} ${read2} > temp.sam

  fi

  # Sort and convert to bam
  gatk SortSam \
  -I temp.sam \
  -O temp.bam \
  -SORT_ORDER coordinate

  # Extract mapping stats
  sambamba flagstat -t \$SLURM_CPUS_ON_NODE temp.bam > ${sample_id}_mapping.log

  # Collect coverage stats with Picard
  picard CollectWgsMetrics \
  R=${reference_fasta} \
  I=temp.bam \
  O=${sample_id}_coverage_stats.txt

  # Add/replace read groups for post-processing with GATK
  picard AddOrReplaceReadGroups \
  I=temp.bam \
  O=temp_rg.bam \
  RGID=${sample_id} \
  RGLB=${sample_id} \
  RGPL=illumina \
  RGPU=${sample_id} \
  RGSM=${sample_id}

  # Mark duplicates
  gatk MarkDuplicates \
  -I temp_rg.bam \
  -O ${sample_id}_merged_mrkdup.bam  \
  -M ${sample_id}_marked_dup_metrics.txt
  """

}