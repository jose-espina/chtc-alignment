#!/bin/bash
#
# pe-align.sh
# CHTC alignment using bowtie2 to mm10
# Usage: pe-align.sh <samplename> <R1-fastq> <R2-fastq>

# mkdir
export HOME=$PWD
mkdir -p input output index

# assign samplename to $1
# assign fastq1 to $2 and fastq2 to $3
samplename=$1
fastq1=$2
fastq2=$3

# copy reads1 and reads2 from staging to input directory
cp /staging/groups/roopra_group/jespina/$fastq1 input
cp /staging/groups/roopra_group/jespina/$fastq2 input

# copy index tar to index directory
cp /staging/groups/roopra_group/jespina/index/mm10.tar.gz index

# unpack index tar
cd index
tar -xzvf mm10.tar.gz
rm mm10.tar.gz
cd ~

# print fastq filename
echo $fastq1 " and " $fastq2
echo "Aligning " $samplename " (paired-end)"

# run bowtie2
bowtie2 --end-to-end --very-sensitive --no-mixed --no-discordant -I 10 -X 700 -p 8 -x index/mm10 \
-1 input/$fastq1 -2 input/$fastq2 -S output/${samplename}_bowtie2.sam &> ${samplename}_bowtie2.txt 

# tar output and move to staging
tar -czvf ${samplename}_bowtie2.tar.gz output/
mv ${samplename}_bowtie2.tar.gz /staging/groups/roopra_group/jespina

# before script exits, remove files from working directory
rm -r input output index

###END
