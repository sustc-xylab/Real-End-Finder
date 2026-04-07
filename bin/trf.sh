#!/bin/bash
set -e

input_file="$1"
num_threads="${2:-1}"
dir=$3
out=${input_file}_trf

# 获取文件名（不含路径）
filename=$(basename "$input_file")

if [ ! -d $out ]; then
        mkdir $out;
else
        echo "Warning: $out already exists. previous results are overwrited"
                rm -rf $out
                mkdir -p $out
fi

# Run TRF command
trf "$input_file" 2 7 7 80 10 50 500 -f -d -m

# 使用文件名而不是完整路径来移动文件
mv $filename.2.7.7.80.10.50.500.*  $out 2>/dev/null || true
mv $filename.*.2.7.7.80.10.50.500.* $out 2>/dev/null || true

echo "Finish identify TRF"

# Merge TRF output
cd $out
cat *.txt.html > TRF.txt

# Extract required information
grep 'Sequence: contig\|Length:\|Indices\|PeriodIndices\|Period size:' TRF.txt > TEST.txt
sed -i '/Left/d' TEST.txt
sed -i '/Right/d' TEST.txt
grep "Sequence:" TEST.txt | sed 's/Sequence: //' > "$dir/REF-trf.csv"
cd -
echo "Processing complete. Output file is $dir/REF-trf.csv"
