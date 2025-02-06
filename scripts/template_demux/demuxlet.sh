#!/bin/bash
#$ -cwd
#$ -o logs/A02a_demuxlet.$JOB_ID
#$ -j y
#$ -N A02a_demuxlet
#$ -l h_data=4G,h_rt=1:00:00
#$ -pe shared 2

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

POPSCLE=/u/project/cluo/terencew/programs/popscle/bin/popscle

BARCODES=$1
VCF=$2
PILEUP=$3
OUT=$4

echo $OUT

time $POPSCLE demuxlet --plp $PILEUP \
  --group-list $BARCODES \
  --field GT \
  --vcf $VCF --out $OUT

echo " "
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
