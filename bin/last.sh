#!/bin/bash
set -e

# Check if enough input files are provided
#if [ "$#" -ne 4 ]; then
#    echo "Usage: $0 <input_file> <input_nanoporefile> <threads> <DIR>"
#    exit 1
#fi

input_file="$1"
input_nanoporefile="$2"
N_threads="$3"
DIR="$4"
out=${input_file}_last

if [ ! -d $out ]; then
        mkdir $out;
else
        echo "Warning: $out already exists. previous results are overwrited"
		rm -rf $out
		mkdir -p $out
fi

# Debugging: print the input files
echo "Input file: $input_file"
echo "Nanopore file: $input_nanoporefile"
echo "Threads: $N_threads"
echo "Directory: $DIR"


#Counting the length of nanopore reads and contigs
awk '/^>/{print $input_nanoporefile; getline; print; while(getline && !/^>/) print}' $input_nanoporefile > $out/output.fa
awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length($0)}END{print l}' $out/output.fa > $out/nanoporesizetmp.txt
awk '/^>/ {sub(/^>/, ""); printf("\n%s ", $0); next} {printf("%s", $0)} END {printf("\n")}' $out/nanoporesizetmp.txt > $out/nanoporesize.txt
awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length($0)}END{print l}' "$input_file" > $out/contigsizetmp.txt
awk '/^>/ {sub(/^>/, ""); printf("\n%s ", $0); next} {printf("%s", $0)} END {printf("\n")}' $out/contigsizetmp.txt > $out/contigsize.txt

#Building a nanopore database
lastdb -Q 0 Nanopore.fasta_lastindex "$input_file" -P "$N_threads"
mv Nanopore.fasta_lastindex.* $out
echo "Done build last index"

lastal -T 0 -a 1 -P "$N_threads" -f BlastTab $out/Nanopore.fasta_lastindex "$input_nanoporefile" > $out/total.fa_last
echo "Done last alignment"


echo "Parsing last alignment"
# remove alignments with similarity < 80%
awk '$3 > 80' $out/total.fa_last > $out/total.fa_last.modified

fgrep -v "#" $out/total.fa_last.modified > $out/total.fa_last.modified2

# add query and subject length to alignment
${DIR}/bin/FastA.length.pl $input_file > $input_file.length
${DIR}/bin/BlastTab.addlen.sh \
		$input_file \
		$input_nanoporefile \
		$out/total.fa_last.modified2 \
		$DIR \
		$out/total.fa_last.80modified

mv $input_file.length $out

# parse results in R
cd $out
Rscript "${DIR}/bin/filteredge2.R" 
mv REF-nanopore.csv ..
cd ..

# Remove intermediate files
rm $out/total.fa_last.modified2 $out/total.fa_last.modified
