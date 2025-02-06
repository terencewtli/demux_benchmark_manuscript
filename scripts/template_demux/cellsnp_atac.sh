#!/bin/bash
#$ -cwd
#$ -o logs/A01b_cellsnp_atac.$JOB_ID
#$ -j y
#$ -N A01b_cellsnp_atac
#$ -l h_data=2G,h_rt=12:00:00
#$ -pe shared 10

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

CELLSNP=/u/project/cluo/terencew/programs/cellsnp-lite/bin/cellsnp-lite

BAM=$1
BARCODES=$2
VCF=$3
OUT=$4

time $CELLSNP -s ${BAM} -b ${BARCODES} \
  -O $OUT -R ${VCF} -p 50 \
  --minMAF 0.1 --minCOUNT 20 --gzip --UMItag None

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
