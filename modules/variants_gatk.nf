process VariantsGATK {

  // Variant calling with GATK
  
  label 'variantcalling'

  publishDir "${projectDir}/${sample_id}/${params.variants_out}", mode: "copy", pattern: "*_{gatk.g,gatk_unfilt,gatk_filt}.vcf.gz"

  input:
  tuple val(sample_id), path(bam), path(reference_fasta)

  output:
  tuple val(sample_id), path("${sample_id}_gatk.g.vcf.gz"), path(reference_fasta), emit: gatk_gvcf
  tuple val(sample_id), path("${sample_id}_gatk_unfilt.vcf.gz"), path(reference_fasta), emit: gatk_vcf_unfilt
  tuple val(sample_id), path("${sample_id}_gatk_filt.vcf.gz"), path(reference_fasta), emit: gatk_vcf_filt

  """
  # Index reference fasta
  samtools faidx ${reference_fasta}

  # Index bam
  samtools index ${bam}

  # Generate GATK dictionary
  gatk CreateSequenceDictionary -R ${reference_fasta}

  if [ ${params.variants_only} == false ]
  then 
  
    # Call variants with GATK, output GVCF
    # ERC: Reference model emitted with condensed non-variant blocks, i.e. the GVCF format
    gatk --java-options "-Xmx4g" HaplotypeCaller \
    -R ${reference_fasta} \
    -ploidy ${params.ploidy} \
    -I ${bam} \
    -ERC BP_RESOLUTION \
    --output-mode EMIT_ALL_CONFIDENT_SITES \
    -O ${sample_id}_gatk.g.vcf.gz

    # GVCF to VCF. Min base quality score is 10 by default. Including non-variant sites in order to differentiate between consensus call and no-call sites
    gatk --java-options '-Xmx100g' GenotypeGVCFs \
    -R ${reference_fasta} \
    --variant ${sample_id}_gatk.g.vcf.gz \
    -ploidy ${params.ploidy} \
    --include-non-variant-sites true \
    --output ${sample_id}_gatk_unfilt.vcf.gz
  
  else

    # Call variants with GATK, output GVCF
    # ERC: Reference model emitted with condensed non-variant blocks, i.e. the GVCF format
    gatk --java-options "-Xmx4g" HaplotypeCaller \
    -R ${reference_fasta} \
    -ploidy ${params.ploidy} \
    -I ${bam} \
    -ERC GVCF \
    --output-mode EMIT_VARIANTS_ONLY \
    -O ${sample_id}_gatk.g.vcf.gz

    # GVCF to VCF. Min base quality score is 10 by default.
    gatk --java-options '-Xmx100g' GenotypeGVCFs \
    -R ${reference_fasta} \
    --variant ${sample_id}_gatk.g.vcf.gz \
    -ploidy ${params.ploidy} \
    --include-non-variant-sites false \
    --output ${sample_id}_gatk_unfilt.vcf.gz
  
  fi

  # Use bcftools to filter - can only apply one expression at a time.
  bcftools filter --soft-filter 'lowQual' --exclude '(QUAL < ${params.qual_threshold} && QUAL != ".") || RGQ < ${params.qual_threshold}' ${sample_id}_gatk_unfilt.vcf.gz | \
  bcftools filter --soft-filter 'lowDepth' --exclude 'FORMAT/DP < ${params.depth_threshold}' -O z -o ${sample_id}_gatk_filt.vcf.gz
  """

}
