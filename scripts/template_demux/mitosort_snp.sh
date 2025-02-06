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

VARSCAN=

BAM=$1
CELL=$2
MITO=$3
OUT=$4

time $MITOSORT generate-snp-matrix \
    -b $BAM \
    -f $FASTA \
    -c $CELL \
    -m $MITO \
    --varscan_path $VARSCAN \
    -o $OUT

#     -c /path/to/singlecell.csv -m /path/to/MitoSort/data/hg38_chrM.bed --varscan_path /path/to/VarScan.v2.3.7.jar -o /path/to/output_dir
# 
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
