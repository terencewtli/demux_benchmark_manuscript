#!/bin/bash
#$ -cwd
#$ -o logs/A02b_freemuxlet.$JOB_ID
#$ -j y
#$ -N A02b_freemuxlet
#$ -l h_data=8G,h_rt=4:00:00
#$ -pe shared 2

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

POPSCLE=/u/home/t/terencew/project-cluo/programs/popscle/bin/popscle

BARCODES=$1
N_DONORS=$2
PILEUP=$3
OUT=$4
SEED=$5
DBL_PRIOR=$6
GENO_ERROR=$7
MIN_SNP=$8

time $POPSCLE freemuxlet --plp $PILEUP \
  --group-list $BARCODES \
  --nsample $N_DONORS \
  --aux-files \
  --out $OUT \
  --doublet-prior $DBL_PRIOR \
  --geno-error $GENO_ERROR \
  --min-snp $MIN_SNP \
  --seed $SEED

echo " "
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
