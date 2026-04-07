#!/bin/bash
set -e

# 参数说明：
# $1: db_fasta (数据库fasta文件)
# $2: Query (查询文件)
# $3: blast_tab (blast结果文件)
# $4: DIR (脚本目录)
# $5: output (输出文件)

db_fasta="$1"
Query="$2"
blast_tab="$3"
DIR="$4"
output="$5"

# 获取文件名（不含路径）
query_name=$(basename "$Query")
db_name=$(basename "$db_fasta")

# 创建临时目录
tmp_dir="tmp_${query_name%.*}"
mkdir -p "$tmp_dir"

# 修复：使用文件名而不是完整路径
cut -f 2 "${blast_tab}" | sort -u > "${tmp_dir}/${query_name}.list"
fgrep -f "${tmp_dir}/${query_name}.list" "${db_fasta}.length" > "${tmp_dir}/${db_name}.length"

"$DIR/bin/fastaNameLengh.pl" "$Query" > "${Query}.length"
