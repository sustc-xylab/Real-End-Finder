# Real-End-Finder
**Real End Finder** 
## Dsecription
The Real End Finder (REF) is designed to address the issue of determining the completeness of linear fragments like plasmid conitgs. Linear fragments are commonly observed when assembling sequences, particularly when the coverage of assembled contigs is high and they do not form circular structures. In such cases, the REF can be utilized to assess the completeness of linear fragments.
Before using this tool, it is crucial to ensure that the discussed fragments possess the relevant characteristics. For example, if you want to determine whether a fragment is a complete linear plasmid, it must first exhibit the characteristics associated with plasmids. This step is essential, as it forms the foundation for accurate analysis.
Please read below instructions carefully to avoid unnecessary errors.

## Installation 
### Pre-requisites for REF (Please contact your administrator for installation to ensure they can call it directly in the command line)
	
	python2.7	### sudo apt install python2.7
	BWA 	### git clone https://github.com/lh3/bwa.git; cd bwa; make
	LAST	### sudo apt install python2.7
	SAMTOOLS	### git clone https://github.com/samtools/samtools/releases/; tar -jxvf samtools-1.19.2.tar.bz2; cd samtools-1.19.2；./configure; sudo make install
	TRF	### git clone https://github.com/Benson-Genomics-Lab/TRF.git; cd TRF; mkdir build; ../configure; make; sudo make install
	R4.1.0 	### conda install r-base=4.1.0
	R packages	### R; install.packages("dplyr"), install.packages("data.table") 

### Setup REF
	
	git clone https://github.com/sustc-xylab/REF.git
	
	cd REF
	
	bash ./REF.sh	



## Using REF 
To ensure the commands run properly, all software to be analyzed should be placed in one folder.

	mkdir -p demo
	cp test.fa testillumina1.fa testillumina2.fa testnanopore.fa demo 
	cd demo 
	bash REF.sh -f test.fa -i testillumina1.fa -j testillumina2.fa -l 150 -n testnanopore.fa -t 30
Arguments:
	-h	display this help 
	-f contigs.fasta: Specifies the input file contigs.fasta.
	-i illumina_1.fa: Specifies the input file illumina.fa with forward paired-end reads
 	-j illumina_2.fa: Specifies the input file illumina.fa with reverse paired-end reads
	-l Read_l: illumina reads length
	-n nanopore.fa: Specifies the input file nanopore.fa.
	-t 30: Specifies the number of threads for parallel processing.
	
 **NOTICE**: 
	Make sure there are no previous intermediate files/directories in the current working directory.
	One given working directory can only be used by one instance of "REF" run.
	If you only want to verify whether a specific item meets the integrity criteria, you can directly call bin/trf.sh, bin/bwa.sh, or bin/last.sh.
	The length of all Illumina short reads should be the same.
	The illumina.fa file must be provided because Illumina's evidence serves as stronger support.
	Due to issues with nanopore sequencing data, we provided a 10bp allowance, and the alignment length should be greater than 1000bp, covering 80% of the target region.
#### Output files 
All output files of REF are stored in a folder named $INPUT_FASTA_REF_nowtime in the working directory.
Main output files include:
	
	REF-trf.txt 	Contigs that satisfy TRF judgment
	REF-illumina.csv	Contigs that satisfy illumina reads alignment judgment
	REF-nanopore.csv	Contigs that satisfy nanopore reads alignment judgment
	REF-all.csv 	Contigs that satisfy all judgments

 **NOTICE**: 
 	If you want to find the information corresponding to the three conditions, please look in the current folder for:
	intermediate.files/$INPUT_FASTA_trf: To see the overall situation, view summary.html; for the tandem repeat status of a specific sequence, check the corresponding.txt.html.
	intermediate.files/$INPUT_FASTA_bwa: To check the overall alignment, refer to the SAM file. You can use 
    samtools view -bS *.sam > *.bam
    samtools view -f 4 *.bam | less -S  # reads are unmapped
    samtools view -F 4 *.bam | less -S  # reads are mapped
	intermediate.files/$INPUT_FASTA_last: To check the overall alignment,  You can use "less -S total.fa_last.80modified".


## *Citation:*
If you use REF in your completeness analysis please cite:
Yuxi Yan, Ziqi Wu, Yuhong Sun, Miao Zhang, Bixi Zhao, Cailong Nie, Zhanwen Cheng, Qing Yang, Liming Chen, Qiqi Hao, Bing Fu, Yu Xia*. 2026. Insights into the conjugative plasmidome of biological wastewater treatment system by coupling filter-mating and nanopore selective sequencing. 


##### Tools included in REF should be also cited, these tools includes: 
last, bwa, samtools, trf, R, python
