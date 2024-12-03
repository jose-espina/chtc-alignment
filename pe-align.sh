#!/bin/bash
#
# pe-align.sh
# CHTC alignment using bowtie2 to mm10
# Usage: pe-align.sh <samplename> <R1 and R2 tar>

# mkdir
export HOME=$PWD
mkdir -p input output index

# assign samplename to $1
# assign reads to $2
samplename=$1
reads=$2

# copy trimmed_fq.tar.gz from staging to input directory and unpack
cp /staging/groups/roopra_group/jespina/$reads input
cd input
tar -xzvf $reads

# assign fastq1 and fastq2 to R1 and R2 reads
fastq1=$(ls *R1_001_trimmed.fq.gz)
fastq2=$(ls *R2_001_trimmed.fq.gz)

# remove tar containing the reads
rm $reads
cd ~

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

# run bowtie2 alignment
bowtie2 --end-to-end --very-sensitive --no-mixed --no-discordant -I 10 -X 700 -p 8 -x index/mm10 \
-1 input/$fastq1 -2 input/$fastq2 -S output/${samplename}_bowtie2.sam &> ${samplename}_bowtie2.txt 

# convert .sam to .bam using samtools
samtools view -h -S -b \
-o output/${samplename}_bowtie2.bam \
output/${samplename}_bowtie2.sam

# sort and index bam file
samtools sort output/${samplename}_bowtie2.bam -o output/${samplename}_bowtie2_sorted.bam
cd output
samtools index -b ${samplename}_bowtie2_sorted.bam

# tar sam and move to staging
tar -czvf ${samplename}_bowtie2.sam.tar.gz ${samplename}_bowtie2.sam
mv ${samplename}_bowtie2.sam.tar.gz /staging/groups/roopra_group/jespina

# move sorted bam and index to staging for next step 
mv ${samplename}_bowtie2_sorted.bam /staging/groups/roopra_group/jespina
mv ${samplename}_bowtie2_sorted.bam.bai /staging/groups/roopra_group/jespina
cd ~

# before script exits, remove files from working directory
rm -r input output index

###END
