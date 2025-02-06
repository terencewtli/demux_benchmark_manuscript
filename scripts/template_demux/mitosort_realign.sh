#!/bin/bash
#$ -cwd
#$ -o logs/A03a_mitosort_realign.$JOB_ID
#$ -j y
#$ -N A03a_mitosort_realign
#$ -l h_data=2G,h_rt=8:00:00,h_vmem=8G
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate MitoSort

MITOSORT=/u/project/cluo/terencew/programs/MitoSort/MitoSort_pipeline.py
GATK=/u/project/cluo/terencew/programs/gatk/gatk

### do I allow customize?
FASTA=/u/project/cluo/terencew/reference/hg38/hg38.fa

BAM=$1
OUT=$2

time $MITOSORT mt-realign \
  -b $BAM \
  -f $FASTA \
  --gatk_path $GATK \
  -o $OUT

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
