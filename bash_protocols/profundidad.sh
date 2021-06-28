
eval "$(conda shell.bash hook)"
conda activate ohgenom

# variables
output_file="/home/generico/cw_onehealth_protocols/seq_prueba/analysis/metrics.tsv"
articPath=/home/generico/cw_onehealth_protocols/seq_prueba/
printf "%b\t" "Barcode" "# bases" "Avg. depth" >> $output_file

for barcode in $(seq -f "%02g" 1 70); do
    barcode=barcode${barcode}
    bwa index -p $barcode ${articPath}/res_${barcode}/${barcode}.consensus.fasta #construcción del índice

    bwa mem $barcode ${articPath}/barcode/${barcode}/filtered_${barcode}.fastq > aln_${barcode}.sam #alineamiento de fastq a secuencia consenso

    samtools view -S -b aln_${barcode}.sam > aln_${barcode}.bam #pasar a bam

     samtools sort aln_${barcode}.bam -o aln_${barcode}-sorted.bam #sorting

numero_bases=$(samtools mpileup aln_${barcode}-sorted.bam | awk -v X="${MIN_COVERAGE_DEPTH}" '$4>=X' | wc -l)

promedio_soporte=$(samtools depth aln_${barcode}-sorted.bam | awk '{sum+=$3} END { print "Average = ",sum/NR}')

printf "%b\t" "\n${barcode}" "${numero_bases}" "${promedio_soporte}" >> $output_file
done < $1 
