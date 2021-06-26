### Input variables:

# $1: input experiment folder with the fast5 folder inside
# $2: list of barcode's names


#PASO 0: Generación de carpetas y activación del entorno

#module load Guppy/3.0.3
eval "$(conda shell.bash hook)"
conda activate ohgenom

#rm -r $1/all_consensus
#rm -r $1/fastq
#rm -r $1/barcode
#rm -r $1/alignments
#rm -r $1/pilon

#mkdir $1/barcode
#mkdir $1/guppy
#mkdir $1/fastq
#mkdir $1/assembly

#PASO 1: Basecalling
#guppy_basecaller -i $1/fast5/ -s $1/guppy/ -c dna_r9.4.1_450bps_fast.cfg --cpu_threads_per_caller 100 --as_cpu_threads_per_scaler 40 --as_num_scalers 40 --num_alignment_threads 40 --num_callers 1

#Paso 2: Unificación de archivos
#cat $1/guppy/pass/*.fastq > $1/guppy/all.fastq

#Paso 3: Reporte
#fastqc $1/guppy/all.fastq --threads 24

#Paso 4: Remoción de duplicados
#seqkit stats $1/guppy/all.fastq

#seqkit rmdup $1/guppy/all.fastq > $1/guppy/all_rmdup.fastq

#Paso 5: Filtrado de calidad
#cat $1/guppy/all_rmdup.fastq | NanoFilt -q 9 -l 200 --maxlength 3000 > $1/fastq/all_filtered.fastq

#Paso 6: Demultiplexing
#guppy_barcoder [--require_barcodes_both_ends] -t 100 -i $1/fastq/ -s $1/barcode/ --barcode_kits "EXP-NBD196"


#Paso 7:Ensamblaje de novo

barcode_folders=$(find $1/barcode/barcode* -type d)
while read -r line; do
	barcode_name=${line}
	barcode_folder=$1/barcode/${barcode_name}
	echo "Processing $barcode_name"
	echo "$barcode_folder"
	#cat $barcode_folder/*.fastq > $barcode_folder/$barcode_name.fastq
	spades.py --isolate -k 87 -s $1/barcode/${barcode_name}/${barcode_name}.fastq -t 100 -o ./$1/assembly/res_${barcode_name}/res1
	spades.py --isolate -k 89 -s $1/barcode/${barcode_name}/${barcode_name}.fastq -t 100 -o ./$1/assembly/res_${barcode_name}/res2
	spades.py --isolate -k 91 -s $1/barcode/${barcode_name}/${barcode_name}.fastq -t 100 -o ./$1/assembly/res_${barcode_name}/res3
	spades.py --isolate -k 93 -s $1/barcode/${barcode_name}/${barcode_name}.fastq -t 100 -o ./$1/assembly/res_${barcode_name}/res4
	spades.py --isolate -k 95 -s $1/barcode/${barcode_name}/${barcode_name}.fastq -t 100 -o ./$1/assembly/res_${barcode_name}/res5
	cap3 $1/assembly/res_${barcode_name}/res1/contigs.fasta > $1/assembly/res_${barcode_name}/res1/output.txt	
	cap3 $1/assembly/res_${barcode_name}/res2/contigs.fasta > $1/assembly/res_${barcode_name}/res2/output.txt
	cap3 $1/assembly/res_${barcode_name}/res3/contigs.fasta > $1/assembly/res_${barcode_name}/res3/output.txt
	cap3 $1/assembly/res_${barcode_name}/res4/contigs.fasta > $1/assembly/res_${barcode_name}/res4/output.txt
	cap3 $1/assembly/res_${barcode_name}/res5/contigs.fasta > $1/assembly/res_${barcode_name}/res5/output.txt	
done < $2
	
