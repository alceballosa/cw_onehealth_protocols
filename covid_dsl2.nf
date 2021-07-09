nextflow.enable.dsl=2

// params.source_folder = "/home/generico/oh-dev/nextflow_testing/covid_samples"
// params.scheme_folder = "/home/generico/oh-dev/cw_onehealth_protocols/protocol_input_files/primer_schemes"
// params.output_folder = params.source_folder+"/results"
 params.threads_basecalling = "32"
 params.threads_minion = "16"
// params.barcode_kit = "EXP-NBD196"



process BASECALLING {
  /*
  Receives the input fasta files as an input and carries out the basecalling process.

  The resulting files are all joined into a single file which is then passed to the
  next process.

  The intermediate files are stored in the source folder
  */

  echo true

  output:
  path 'basecalled_folder'

  script:
  """
  guppy_basecaller -i ${params.source_folder}/fast5/ -s ${params.source_folder}/guppy/ -c dna_r9.4.1_450bps_fast.cfg --cpu_threads_per_caller ${params.threads_basecalling} --as_cpu_threads_per_scaler ${params.threads_basecalling} --as_num_scalers 32 --num_alignment_threads ${params.threads_basecalling} --num_callers 1 --resume
  mkdir basecalled_folder
  cat ${params.source_folder}/guppy/pass/*.fastq > basecalled_folder/all.fastq
  """
}


process DEMULTIPLEXING {

  /*
  The input data is demultiplexed into several files, organized into folders per barcode.
  */

  echo true
  input:
    path basecalled_folder

  output:
    path 'barcode*'

  script:
    """
    guppy_barcoder [--require_barcodes_both_ends] -t ${params.threads_basecalling} -i $basecalled_folder -s ./ --barcode_kits ${params.barcode_kit}
    """
}

process BARCODE_PROCESSING {

  /*
  Processes each barcode with the artic minion pipeline.

  Resulting files are stored both at the all_outputs folder -detailed output- and the consensus_only folder -only the consensus fasta file-.

  */

  maxForks 3
  echo true

  publishDir "${params.output_folder}/all_outputs", pattern: "res_${barcode_folder.baseName}/*", mode:'copy'
  publishDir "${params.output_folder}/consensus_only", pattern: "${barcode_folder.baseName}.consensus.fasta", mode:'copy'

  input:
    path barcode_folder

  output:
    path "res_${barcode_folder.baseName}/*"
    path "${barcode_folder.baseName}.consensus.fasta"

  script:
  """

  artic guppyplex --min-length 400 --max-length 700 --directory ${barcode_folder} --output ${barcode_folder}/filtered_${barcode_folder.baseName}.fastq

  mkdir res_${barcode_folder.baseName}

  artic minion --normalise 200 --threads ${params.threads_minion} --scheme-directory ${params.scheme_folder} --read-file ${barcode_folder}/filtered_${barcode_folder.baseName}.fastq --fast5-directory ${params.source_folder}/fast5/ --sequencing-summary ${params.source_folder}/guppy/sequencing_summary.txt nCoV-2019/V3 res_${barcode_folder.baseName}/${barcode_folder.baseName} --bwa

  cp res_${barcode_folder.baseName}/${barcode_folder.baseName}.consensus.fasta ./${barcode_folder.baseName}.consensus.fasta
  """
}

workflow{
  basecalled_folder = BASECALLING()
  barcode_folders = DEMULTIPLEXING(basecalled_folder)
  barcode_folders_ch = barcode_folders.flatten()
  BARCODE_PROCESSING(barcode_folders_ch)
}
