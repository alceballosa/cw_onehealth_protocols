
## ----------Carpeta bioinfor---------------###

#$1: input folder with the fast5 files.
#$2: reference genome path
#$3: list of barcode names

#conda activate artic-ncov2019

#module load Guppy/3.0.3

eval "$(conda shell.bash hook)"
conda activate ohgenom


#rm -r $1/all_consensus
#rm -r $1/fastq
#rm -r $1/barcode
rm -r $1/alignments
rm -r $1/pilon

mkdir $1/barcode
mkdir $1/guppy 
mkdir $1/fastq
mkdir $1/alignments
mkdir $1/pilon
#PASO 1: Basecalling

#guppy_basecaller -i $1/fast5/ -s $1/guppy/ -c dna_r9.4.1_450bps_fast.cfg --cpu_threads_per_caller 2 --num_callers 1

#Paso 2: Unificación de archivos

#cat $1/guppy/pass/*.fastq > $1/guppy/all.fastq

#Paso 3: Reporte

#fastqc $1/guppy/all.fastq

#Paso 4: Remoción de duplicados

#seqkit stats $1/guppy/all.fastq

#seqkit rmdup $1/guppy/all.fastq > $1/guppy/all_rmdup.fastq

#Paso 5: Filtrado de calidad

#cat $1/guppy/all_rmdup.fastq | NanoFilt -q 9 -l 200 --maxlength 3000 > $1/fastq/all_filtered.fastq

#### Demultiplexing ###
#guppy_barcoder [--require_barcodes_both_ends] -i $1/fastq/ -s $1/barcode/ --barcode_kits "EXP-NBD196" 


##-----------Carpetas dentro de artic ncov2019-------###

#### Read filtering ####

#reference_genomes=$(find $1/references/*.fasta -type f)

barcode_folders=$(find $1/barcode/barcode* -type d)

reference_genome=$2
IFS='/' read -ra reference_gen_filename <<< "$reference_genome"
reference_gen_filename=${reference_gen_filename[-1]}
IFS='.' read -ra reference_gen_filename <<< "$reference_gen_filename"
reference_gen_filename=${reference_gen_filename[0]}
echo "Processing $reference_gen_filename"
mkdir $1/alignments/$reference_gen_filename
while read -r line; do
	barcode_name=${line}
	barcode_folder=$1/barcode/${barcode_name}
	echo "Processing $barcode_name"
	#cat $barcode_folder/*.fastq > $barcode_folder/$barcode_name.fastq
	artic guppyplex --min-length 200 --max-length 3000 --directory $barcode_folder --quality 9 --prefix $barcode_folder/filtered
	seqkit rmdup $barcode_folder/filtered_${barcode_name}.fastq > $barcode_folder/filtered_nodup_$barcode_name.fastq
	minimap2 -ax map-ont $reference_genome $barcode_folder/filtered_nodup_$barcode_name.fastq > $1/alignments/$reference_gen_filename/aligned_${barcode_name}.sam
	samtools faidx $reference_genome 
	samtools view -bt ${reference_genome}.fai -bS $1/alignments/$reference_gen_filename/aligned_${barcode_name}.sam > $1/alignments/$reference_gen_filename/aligned_${barcode_name}.bam
	samtools sort $1/alignments/$reference_gen_filename/aligned_${barcode_name}.bam -o $1/alignments/$reference_gen_filename/aligned_sorted_${barcode_name}.bam 
	samtools index $1/alignments/$reference_gen_filename/aligned_sorted_${barcode_name}.bam
	samtools idxstats $1/alignments/$reference_gen_filename/aligned_sorted_${barcode_name}.bam	
	samtools mpileup -g -f $reference_genome $1/alignments/$reference_gen_filename/aligned_sorted_${barcode_name}.bam > $1/alignments/$reference_gen_filename/aligned_sorted_${barcode_name}.bcf
	mkdir $1/alignments/$reference_gen_filename/pilon_$barcode_name
	pilon -Xmx16G --variant --vcf --changes --tracks --verbose --genome $reference_genome --unpaired $1/alignments/$reference_gen_filename/aligned_sorted_$barcode_name.bam  --outdir $1/alignments/$reference_gen_filename/pilon_$barcode_name --output pilon_${reference_gen_filename}_$barcode_name > $1/alignments/$reference_gen_filename/pilon_$barcode_name/$reference_gen_filename-$barcode_name.out		     
	cp $1/alignments/$reference_gen_filename/pilon_$barcode_name/pilon_${reference_gen_filename}_${barcode_name}.fasta $1/pilon/
	done < $3
	#break




