# Variant calling pipeline

Containerized Nextflow pipeline for variant calling using GATK and LoFreq.

## Processes description

**TrimFastQ**

  Trims reads and runs FastQC.

**ConcatenateLongReads**

  If multiple long reads files are present, they are first concatenated.

**MapReads_BWA**

  Maps reads with BWA, then marks duplicates.

**MapReads_Bowtie**

  Same as above, but using Bowtie2.

**VariantsGATK**

  Variant calling using GATK.

**VariantsLoFreq**

  Same as above, but using LoFreq.

**ConvertVCF**

  Convert single sample VCF to fasta.

## Folder structure

For each sample, results are stored in a folder named using the specified SampleID (see Input below).\
The following subfolders will be present:

<pre>
<b>SampleID</b>
├── <b>bams</b>
│   Aligned bam files.
│
├── <b>fasta</b>
│   Assembled fasta files from the vcf variants.
│
├── <b>reports</b>
│   Subfolder for various reports.
│   │
│   ├── <b>fastqc</b>
│   │   FastQC of raw reads.
│   │
│   ├── <b>trimgalore</b>
│   │   TrimGalore trimming reports.
│   │
│   └── <b>mapping</b>
│       Mapping, coverage, and duplication stats.
│
├── <b>trimmed_fastq</b>
│   Stores the reads trimmed by TrimGalore.
│
└── <b>variants</b>
    Stores the variants in vcf format.
</pre>

## Input

The pipeline reads a tsv file which specifies batches of samples to be analyzed in parallel.\
Specify the path to tsv batch file with the **--data_manifest_path** option (see below).\
The tsv file contains the following fields:

**GenomeID**

  Name of the assembled genome, used to organize the outputs.

**ShortReads_Mate1**

    Absolute path to the mate 1 short paired-end read file.

**ShortReads_Mate2**

    Absolute path to the mate 2 short paired-end read file.
    N.B. single-end, set to mock.fastq.

**Reference**

    Absolute path to the reference to use for mapping and variant calling.

## Usage

Run the pipeline from a Slurm script as:

    nextflow run main.nf

## Options

**--data_manifest_path**

    Path to the sample manifest in tsv format.

**--depth_threshold**

    Minimum threshold for variants filtering.

**--qual_threshold**

    Minimum quality value for variants filtering.

**--ploidy**

    Ploidy of samples (usually 1).

**--variants_only**

    Whether vcf files should report only variant sites or all.

**--run_lofreq**

    Whether to run LoFreq variant calling or not.
    N.B. GATK is always run.
