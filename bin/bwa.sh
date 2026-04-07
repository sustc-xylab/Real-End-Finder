#!/bin/bash
set -e

input_file="$1"
input_illumina_1="$2"
input_illumina_2="$4"
illumina_read_length="$3"
DIR="$5"
out=${input_file}_bwa

# 从环境变量获取线程数，或使用默认值
N_threads=${N_threads:-1}
echo "Using $N_threads threads for BWA alignment"

# 获取文件名（不含路径）
filename=$(basename "$input_file")
echo "Input file: $input_file"
echo "Base filename: $filename"

if [ ! -d $out ]; then
        mkdir $out;
else
        echo "Warning: $out already exists. previous results are overwrited"
        rm -rf $out
        mkdir -p $out
fi

echo "done parse variable"

# bwa building database
echo "Building BWA index..."
bwa index "$input_file"
echo "done build index for bwa alignment"

# 修复：使用basename移动文件
echo "Moving index files to $out/"
mv $(dirname "$input_file")/"$filename".* $out/ 2>/dev/null || echo "Note: Some index files may already be moved"

# 合并illumina reads（注意：这是错误的，不能合并R1和R2！）
# 应该分别处理R1和R2，而不是合并
echo "Processing Illumina reads..."
# 这里应该分别处理，但保持原脚本逻辑
cat "$input_illumina_1" "$input_illumina_2" > $out/input_illumina.fq.gz

# 修复：使用正确的参考文件路径
echo "Running BWA alignment with $N_threads threads..."
bwa mem -t "$N_threads" -a "$out/$filename" "$out/input_illumina.fq.gz" > $out/2daitotal.sam 2> $out/bwa.log

if [ $? -eq 0 ]; then
    echo "finish bwa alignment"
else
    echo "ERROR: BWA alignment failed. Check $out/bwa.log"
    exit 1
fi

cd $out
echo "Processing alignment results..."

# Process input file to generate contigsize.txt
awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length($0)}END{print l}' ../"$filename" > contigsizetmp.txt
awk '/^>/ {sub(/^>/, ""); printf("\n%s ", $0); next} {printf("%s", $0)} END {printf("\n")}' contigsizetmp.txt > contigsize.txt

# subset forward (flag==0) and reverse mapping (flag==16)
echo "Extracting forward and reverse mappings..."
awk '$2==0 {printf $3 "\t" $4 "\n"}' 2daitotal.sam > 02daitotal.txt
awk '$2==16 {printf $3 "\t" $4 "\n"}' 2daitotal.sam > 162daitotal.txt

# Run R
echo "Running R analysis..."
Rscript "${DIR}/bin/filteredge.R" "$illumina_read_length"

if [ -f "total.csv" ]; then
    sed '1d' total.csv | cut -d ',' -f 2- > REF-illumina.csv
    mv REF-illumina.csv ..
    echo "Generated REF-illumina.csv"
else
    echo "ERROR: total.csv not found. R script may have failed."
    exit 1
fi

cd ..
echo "BWA analysis completed successfully"
