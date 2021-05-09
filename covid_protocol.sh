## ----------Carpeta bioinfor---------------###


eval "$(conda shell.bash hook)"
conda activate ohgenom

### Basecalling ###

#guppy_basecaller -i $1/fast5/ -s $1/guppy/ -c dna_r9.4.1_450bps_fast.cfg --cpu_threads_per_caller 100 --as_cpu_threads_per_scaler 40 --as_num_scalers 40 --num_alignment_threads 40 --num_callers 1

#### Demultiplexing ###
#guppy_barcoder [--require_barcodes_both_ends] -t 100 -i $1/guppy/pass/ -s $1/barcode/ --barcode_kits "EXP-NBD196"


##-----------Carpetas dentro de artic ncov2019-------###

#### Read filtering ####

barcode_folders=$(find $1/barcode/barcode* -type d)

mkdir $1/all_consensus


for barcode_folder in $barcode_folders; do
        IFS='/' read -ra barcode_name <<< "$barcode_folder"

        barcode_name=${barcode_name[-1]}
        #echo "$barcode_name"
        #echo "$2"
        echo "Processing $barcode_name"
        artic guppyplex --min-length 400 --max-length 700 --directory $barcode_folder --prefix $barcode_folder/filtered
        mkdir $1/res_$barcode_name
        #echo "Should carry out minion from data in $barcode_folder"
        #echo "Should place files in ${1}/res_$barcode_name/$barcode_name"
        artic minion --normalise 200 --threads 100 --scheme-directory $2 --read-file $barcode_folder/filtered_$barcode_name.fastq --fast5-directory $1/fast5/ --sequencing-summary $1/guppy/sequencing_summary.txt nCoV-2019/V3 $1/res_$barcode_name/$barcode_name --bwa
        #ls -l $1/res_$barcode_name
        cp $1/res_$barcode_name/$barcode_name.consensus.fasta $1/all_consensus/$barcode_name.consensus.fasta

done
