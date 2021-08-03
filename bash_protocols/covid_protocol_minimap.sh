eval "$(conda shell.bash hook)"
conda activate ohgenom
SCHEMES=/home/generico/oh-dev/cw_onehealth_protocols/protocol_input_files/primer_schemes/
FAST5_DIR=/home/generico/oh-dev/cw_onehealth_protocols/local/seq010721/fast5
SEQSUM=/home/generico/oh-dev/cw_onehealth_protocols/local/seq010721/guppy/sequencing_summary.txt
FASTQS=/home/generico/oh-dev/cw_onehealth_protocols/local/seq010721/barcode
filename="/home/generico/oh-dev/cw_onehealth_protocols/local/seq010721/barcodes.txt"
while read -r line; do
	barcode="$line"
	barcode_folder=$FASTQS/$barcode
	echo "Processing $barcode"
        artic guppyplex --min-length 400 --max-length 700 --directory $barcode_folder --prefix $barcode_folder/filtered
	mkdir /home/generico/oh-dev/cw_onehealth_protocols/local/seq010721/res_${barcode}
	cd /home/generico/oh-dev/cw_onehealth_protocols/local/seq010721/res_${barcode}
	artic minion --normalise 200 --threads 32 --scheme-directory ${SCHEMES} --read-file ${FASTQS}/${barcode}/filtered_${barcode}.fastq --fast5-directory ${FAST5_DIR} --sequencing-summary ${SEQSUM} nCoV-2019/V3 ${barcode} 
	#cd /exports/home/genocwohc_med/bosque/ins/ensamblaje
	#cat ${barcode}/${barcode}.consensus.fasta >> /exports/home/genocwohc_med/bosque/ins/ensamblaje/consensus_genomes.fasta;
done < $1
