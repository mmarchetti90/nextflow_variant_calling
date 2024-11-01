
// ----------------Workflow---------------- //

include { VariantsLoFreq } from '../../modules/var_calling/variants_lofreq.nf'

workflow LOFREQ {

  take:
  bam_files
  bam_index
  reference_fasta
  reference_fasta_index
	
  main:
  // LOFREQ VARIANT CALLER ---------------- //

  // Prep input
  bam_files
  .join(bam_files, by: 0, remainder: false)
  .join(bam_index, by: 0, remainder: false)
  .join(reference_fasta, by: 0, remainder: false)
  .join(reference_fasta_index, by: 0, remainder: false)
  .set{lofreq_input}

  // LoFreq
  VariantsLoFreq(bam_files)

}
