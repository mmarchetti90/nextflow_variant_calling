
// ----------------Workflow---------------- //

include { IndexFastaSamtools } from '../modules/joint_calling/indexing/index_fasta_samtools.nf'
include { Dorado } from '../modules/joint_calling/basecalling/dorado.nf'
include { Minimap2 } from '../modules/joint_calling/mapping/map_reads_minimap2.nf'
include { Postprocess_ONT } from '../modules/joint_calling/mapping/postprocess_ont.nf'
include { IndexBam } from '../modules/common/indexing/index_bam.nf'
include { GATK } from '../subworkflows/joint_calling/gatk_calling.nf'

workflow JOINTCALLING_ONT {

  // LOADING RESOURCES -------------------- //

  // Reference fasta channel
  Channel
  .fromPath("${params.reference_fasta}")
  .set{reference_fasta}

  // Index fasta
  IndexFastaSamtools(reference_fasta)

  // BASECALLING -------------------------- //

  if (params.skip_basecalling == true) {

    // Input is already basecalled

    // Loading basecalled bams
    Channel
      .fromPath("${params.data_manifest_path}")
      .splitCsv(header: true, sep: '\t')
      .map{ row -> tuple(row.SampleID, file(row.ReadsPath)) }
      .set{ basecalled_ont }

  }
  else {

    // Loading FAST5/POD5 list file
    Channel
      .fromPath("${params.data_manifest_path}")
      .splitCsv(header: true, sep: '\t')
      .map{ row -> tuple(row.SampleID, file(row.InputPath)) }
      .set{ input_dirs }

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

  // GATK variant calling
  GATK(bam_files, IndexBam.out.bam_index, reference_fasta, IndexFastaSamtools.out.reference_fasta_index)

}