#!/bin/bash
#$ -cwd
#$ -o logs/A02f_souporcell_atac.$JOB_ID
#$ -j y
#$ -N A02f_souporcell_atac
#$ -l h_data=2G,h_rt=8:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate souporcell

SOUPORCELL=/u/project/cluo/terencew/programs/souporcell/souporcell_pipeline.py
FASTA=/u/project/cluo/terencew/reference/hg38/fasta/hg38.fa

BARCODES=$1
BAM=$2
N_DONORS=$3
OUT=$4
FASTA=$5
VCF=$6

time $SOUPORCELL -i $BAM -b $BARCODES \
  -f $FASTA -t 50 -o $OUT -k $N_DONORS \
  --no_umi True --known_genotypes $VCF \
  --restarts 200 --skip_remap True

  # --restarts 200 --min_alt 1 --min_ref 1 \

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
