#!/bin/bash
#$ -cwd
#$ -o logs/A02b_freemuxlet.$JOB_ID
#$ -j y
#$ -N A02b_freemuxlet
#$ -l h_data=8G,h_rt=2:00:00
#$ -pe shared 1

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

echo $OUT

time $POPSCLE freemuxlet --plp $PILEUP \
  --group-list $BARCODES \
  --nsample $N_DONORS \
  --aux-files \
  --out $OUT \
  --seed $SEED

echo " "
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
