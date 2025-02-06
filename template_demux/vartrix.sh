#!/bin/bash
#$ -cwd
#$ -o logs/vartrix.$JOB_ID
#$ -j y
#$ -N vartrix
#$ -l h_data=6G,h_rt=8:00:00
#$ -pe shared 14

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

FASTA=/u/project/cluo/terencew/reference/hg38/fasta/hg38.fa
MAPQ=30

BAM=$1
BARCODES=$2
VCF=$3
OUT=$4

REF=$OUT/ref.mtx
ALT=$OUT/alt.mtx

VARTRIX=/u/project/cluo/terencew/programs/bin/vartrix

time $VARTRIX -b $BAM -v $VCF --fasta $FASTA \
    -c $BARCODES --out-matrix $ALT \
    --ref-matrix $REF --mapq $MAPQ \
    --scoring-method coverage --threads 50

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
