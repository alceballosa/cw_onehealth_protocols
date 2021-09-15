nextflow.enable.dsl=2

process BASECALLING {
  /*
  Receives the input fasta files as an input and carries out the basecalling process.

  The resulting files are all joined into a single file which is then passed to the
  next process.

  The intermediate files are stored in the source folder

  If required, you can resume the guppy_basecaller execution. HOWEVER, this will only
  work if it is possible to resume. That is, you can't leave the resume flag active
  by default or you will face exceptions when trying to run guppy_basecaller from the
  ground up.

  In order to resume, add the '--resume' flag at the end of the guppy_basecaller line.
  */

  echo true

  publishDir "${params.output_folder}/", pattern: "${params.source_folder}/guppy/sequencing_summary.txt", mode:'copy'

  output:
  path 'basecalled_folder'

  script:
  """
  guppy_basecaller -i ${params.source_folder}/fast5/ -s ${params.source_folder}/guppy/ -c dna_r9.4.1_450bps_fast.cfg --cpu_threads_per_caller ${params.threads_basecalling} --as_cpu_threads_per_scaler ${params.threads_basecalling} --as_num_scalers 32 --num_alignment_threads ${params.threads_basecalling} --num_callers 1
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

  errorStrategy 'ignore'

  maxForks 3
  echo true

  publishDir "${params.output_folder}/all_outputs", pattern: "res_${barcode_folder.baseName}/*", mode:'copy'
  publishDir "${params.output_folder}/consensus_only", pattern: "${barcode_folder.baseName}.consensus.fasta", mode:'copy'
  publishDir "${params.output_folder}/filtered_barcodes", pattern: "${barcode_folder}/filtered_${barcode_folder.baseName}.fastq", mode:'copy'

  input:
    path barcode_folder

  output:
    path "res_${barcode_folder.baseName}/*"
    path "${barcode_folder.baseName}.consensus.fasta"
    path "${barcode_folder}/filtered_${barcode_folder.baseName}.fastq"
  script:
  """

  artic guppyplex --min-length 400 --max-length 700 --directory ${barcode_folder} --output ${barcode_folder}/filtered_${barcode_folder.baseName}.fastq

  mkdir res_${barcode_folder.baseName}

  artic minion --normalise 200 --threads ${params.threads_minion} --scheme-directory ${params.primers_folder} --read-file ${barcode_folder}/filtered_${barcode_folder.baseName}.fastq --fast5-directory ${params.source_folder}/fast5/ --sequencing-summary ${params.source_folder}/guppy/sequencing_summary.txt nCoV-2019/V3 res_${barcode_folder.baseName}/${barcode_folder.baseName} --bwa || artic minion --normalise 200 --threads ${params.threads_minion} --scheme-directory ${params.primers_folder} --read-file ${barcode_folder}/filtered_${barcode_folder.baseName}.fastq --fast5-directory ${params.source_folder}/fast5/ --sequencing-summary ${params.source_folder}/guppy/sequencing_summary.txt nCoV-2019/V3 res_${barcode_folder.baseName}/${barcode_folder.baseName}

  cp res_${barcode_folder.baseName}/${barcode_folder.baseName}.consensus.fasta ./${barcode_folder.baseName}.consensus.fasta
  """
}

workflow{
  basecalled_folder = BASECALLING()
  barcode_folders = DEMULTIPLEXING(basecalled_folder)
  barcode_folders_ch = barcode_folders.flatten()
  BARCODE_PROCESSING(barcode_folders_ch)
}
