
// ----------------Workflow---------------- //

include { IndexFastaSamtools } from '../modules/joint_calling/indexing/index_fasta_samtools.nf'
include { MakeGATKDict } from '../modules/joint_calling/indexing/make_gatk_dict.nf'
include { Dorado } from '../modules/joint_calling/basecalling/dorado.nf'
include { Minimap2 } from '../modules/joint_calling/mapping/map_reads_minimap2.nf'
include { Postprocess_ONT } from '../modules/joint_calling/mapping/postprocess_ont.nf'
include { IndexBam } from '../modules/common/indexing/index_bam.nf'
include { Clair3GVCF } from '../modules/joint_calling/var_calling/clair3_gvcf.nf'
include { IndexVcfGATK as IndexSingle } from '../modules/common/indexing/index_vcf_gatk.nf'
include { CombineGVCFs } from '../modules/joint_calling/var_calling/combine_gvcfs.nf'
include { IndexVcfGATK as IndexCombined } from '../modules/common/indexing/index_vcf_gatk.nf'
include { GenotypeGVCF } from '../modules/joint_calling/var_calling/genotype_gvcf.nf'
include { FilterVCF } from '../modules/common/var_calling/filter_vcf.nf'

workflow JOINTCALLING_ONT {

  // LOADING RESOURCES -------------------- //

  // Reference fasta channel
  Channel
  .fromPath("${params.reference_fasta}")
  .set{reference_fasta}

  // Index fasta
  IndexFastaSamtools(reference_fasta)

  // Create GATK dictionary
  MakeGATKDict(reference_fasta)

  // BASECALLING -------------------------- //

  if (params.skip_basecalling == true) {

    // Input is already basecalled

    // Loading basecalled bams
    Channel
    .fromPath("${params.data_manifest_path}")
    .splitCsv(header: true, sep: '\t')
    .map{ row -> tuple(row.SampleID, file(row.ReadsPath)) }
    .set{basecalled_ont}

  }
  else {

    // Loading FAST5/POD5 list file
    Channel
    .fromPath("${params.data_manifest_path}")
    .splitCsv(header: true, sep: '\t')
    .map{ row -> tuple(row.SampleID, file(row.InputPath)) }
    .set{input_dirs}

    // Dorado basecalling
    Dorado(input_dirs)

    basecalled_ont = Dorado.out.basecalled_ont

  }

  // MAPPING READS ------------------------ //

  Minimap2(reference_fasta, basecalled_ont)

  Postprocess_ONT(reference_fasta, Minimap2.out.aligned_ont)

  bam_files = Postprocess_ONT.out.bam_files

  // Indexing bam
  IndexBam(bam_files)

  // VARIANT CALLING ---------------------- //

  // Prep input for Clair3
  bam_files
  .join(IndexBam.out.bam_index, by: 0, remainder: false)
  .set{bam_input}

  // Variant calling with Clair3
  Clair3GVCF(reference_fasta, IndexFastaSamtools.out.reference_fasta_index, bam_input)

  // Index GVCFs
  IndexSingle(Clair3GVCF.out.clair3_gvcf)

  // Prep input for CombineGVCFs (sample IDs are discarded, only files are kept)
  Clair3GVCF.out.clair3_gvcf
  .join(IndexSingle.out.vcf_index, by: 0, remainder: false)
  .map{ g -> tuple(file(g[1]), file(g[2])) }
  .collect()
  .set{gvcf_files}

  // CombineGVCFs
  CombineGVCFs(reference_fasta, IndexFastaSamtools.out.reference_fasta_index, MakeGATKDict.out.gatk_dict, gvcf_files)

  // Index combined gvcf
  IndexCombined(CombineGVCFs.out.combined_gvcf)

  // Prep input for CombineGVCFs
  CombineGVCFs.out.combined_gvcf
  .join(IndexCombined.out.vcf_index, by: 0, remainder: false)
  .set{indexed_combined_gvcf}

  // Genotyping
  GenotypeGVCF(reference_fasta, IndexFastaSamtools.out.reference_fasta_index, MakeGATKDict.out.gatk_dict, indexed_combined_gvcf)

  // Filtering
  FilterVCF(GenotypeGVCF.out.gatk_vcf_unfilt)

}