#!/bin/bash
#
# fragmentlength.sh
# collecting fragment length data for plotting
# Usage: fragmentlength.sh <bam> 

# mkdir
export HOME=$PWD
mkdir -p input output 

# assign bam to $1
bam=$1

# copy bam and index file from staging to input
cp /staging/jespina/$bam input
cp /staging/jespina/${bam}.bai input

# get basename of bam file
filename=`basename $bam .bam`

# Extract the 9th column from the bam file which is the fragment length
samtools view -F 0x04 input/$bam | awk -F'\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' | sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' > output/${filename}_fragmentLen.txt

# move fragmentLen file to staging
cd output
mv ${filename}_fragmentLen.txt /staging/jespina
cd ~

# before script exits, remove files from working directory
rm -r input output 

###END
