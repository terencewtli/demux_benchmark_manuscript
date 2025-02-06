#!/bin/bash
#$ -cwd
#$ -o logs/A02m_scsplit_count.$JOB_ID
#$ -j y
#$ -N A02m_scsplit_count
#$ -l h_data=4G,h_rt=4:00:00
#$ -pe shared 4

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

SCSPLIT=/u/project/cluo/terencew/programs/scSplit/scSplit

VCF=$1
BAM=$2
BARCODES=$3
COMMON_SNPS=$4
REF=$5
ALT=$6
OUT=$7

time $SCSPLIT count -v $VCF -i $BAM \
  -b $BARCODES -r $REF -a $ALT \
  -c $COMMON_SNPS -o $OUT

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
