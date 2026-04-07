#!/bin/bash
set -e

# creator: Yu Xia 
# Southern University of Science and Technology
# Yuxi Yan
# Southern University of Science and Technology
# Harbin Institute of Technology
# Should you have any question please email to zzuyanyuxi@163.com

## Description and usage information...

show_help() {
cat << EOF
Usage: ${0##*/} 
version 1.0
written by: Yuxi Yan <zzuyanyuxi@163.com>

Arguments:
	-h	display this help 
	-f contigs.fasta: Specifies the input file contigs.fasta.
	-i1 illumina.fa: Specifies the input file illumina.fa with forward paired-end reads
 	-i2 illumina.fa: Specifies the input file illumina.fa with reverse paired-end reads
	-l Read_l: illumina reads length:
	-n nanopore.fa: Specifies the input file nanopore.fa.
	-t 30: Specifies the number of threads for parallel processing.

Output files:
	REF-trf.txt	Contigs that satisfy TRF judgment
	REF-illumina.csv	Contigs that satisfy illumina reads alignment judgment
	REF-nanopore.csv	Contigs that satisfy nanopore reads alignment judgment
	REF-all.csv	Contigs that satisfy all judgments

Example usage: 
	bash REF.sh -f <input_file> -i <input_illuminafile_1> -j <input_illuminafile_2> -l <illumina_read_length> -n <input_nanoporefile> -t 30

NOTICE: 
	Make sure there are no previous intermediate files/directories in the current working directory.
	One given working directory can only be used by one instance of "REF" run.
EOF
}

### arguments ###################
SCRIPT=`realpath $0`
DIR=`dirname $SCRIPT`
nowt=`date +%Y-%m-%d.%H:%M:%S`

OPTIND=1

# set default value:
N_threads="1"
input_fa=""
input_illumina_1=""
input_illumina_2=""
input_nanopore=""
illumina_read_length=""


while getopts "f:i:j:n:t:l:h" opt; do
	case "$opt" in
		h | --help)
			show_help
			exit 0
			;;
		f)
			input_fa=$OPTARG
			;;
		i)
			input_illumina_1=$OPTARG
			;;
 		j)
			input_illumina_2=$OPTARG
			;;
		n)
			input_nanopore=$OPTARG
			;;
		t)
			N_threads=$OPTARG
			;;
		l)
			illumina_read_length=$OPTARG
			;;
		*)
			echo "Invalid option: -$OPTARG" >&2
			show_help >&2
			exit 1
			;;
	esac
done

if [ -z "$input_fa" ]; then
	echo "No input fasta, -f must be specified"
	exit 1
fi

if [ -z "$illumina_read_length" ]; then
	echo "illumina read length is not specified, -l must be provided"
	exit 1
fi

echo "
-----------------------------------------------
Start REF @ `date +"%Y-%m-%d %T"`
"
# First-step: Run REF
echo "REF is running using parameters:
Input fasta: $input_fa
Number of threads: $N_threads
"

# trf.sh
bash "$DIR/bin/trf.sh" "$input_fa" "$N_threads" "$DIR"

echo "
Finish TRF quantification @ `date +"%Y-%m-%d %T"`"

###############################################################
#######          end to end alignment - illumina            ####### 
###############################################################
echo "
----------------------------------------------------------------------------
Start end-check by illumina alignment @ `date +"%Y-%m-%d %T"`"
bash "$DIR/bin/bwa.sh" "$input_fa" "$input_illumina_1"  "$illumina_read_length" "$input_illumina_2" $DIR
echo "
Finish end-check by illumina alignment @ `date +"%Y-%m-%d %T"`"



###############################################################
#######          end to end alignment - nanopore            ####### 
###############################################################
echo "
----------------------------------------------------------------------------
Start end-check with nanopore alignment @ `date +"%Y-%m-%d %T"`"
bash $DIR/bin/last.sh "$input_fa" "$input_nanopore" "$N_threads" "$DIR" 
echo "
Finish end-check nanopore alignment @ `date +"%Y-%m-%d %T"`"

#############################################################################
#######          Final summary that meets the three criteria          ####### 
#############################################################################
# get intersect for TRF, illumina-mapping and nanopore-mapping
awk 'FNR==1 {files++} {count[$0]++} END {for (line in count) if (count[line] == files) print line}' REF-trf.csv REF-illumina.csv REF-nanopore.csv > REF-all.csv


echo "
-----------------------------------------------------------------
Saving REF results 
"
out=`echo "${input_fa}_RFF_${nowt}"`
echo "moving results to $out"
if [ ! -d $out ]; then 
	mkdir $out;
	mkdir $out/intermediate.files
else 
	rm -rf $out
	mkdir -f $out
	mkdir $out/intermediate.files

fi

#mv ${input_fa} ${out}
mv ${input_fa}_trf ${out}/intermediate.files
mv ${input_fa}_bwa ${out}/intermediate.files
mv ${input_fa}_last ${out}/intermediate.files


mv REF-trf.csv ${out}
mv REF-nanopore.csv ${out}
mv REF-illumina.csv ${out}
mv REF-all.csv ${out}


echo "Thank you for using REF！"
echo "
Done REF @ `date +"%Y-%m-%d %T"`
"