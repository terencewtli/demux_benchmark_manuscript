#!/bin/bash
#$ -cwd
#$ -o logs/A02f_ambimux_gex.$JOB_ID
#$ -j y
#$ -N A02f_ambimux_gex
#$ -l h_data=8G,h_rt=6:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

### reference
# GTF=/u/project/cluo/terencew/reference/hg38/gtf/gencode.v39.annotation.gtf
# EXCL=/u/project/cluo/terencew/reference/hg38/bed/hg38-blacklist.v2_noheader.bed
WL_BCS=/u/project/cluo/terencew/reference/barcodes/rna_cr_arc-v1.txt
AMBIMUX=/u/home/t/terencew/project-cluo/programs/ambimux/ambimux

RNA_BAM=$1
PEAKS=$2
VCF=$3
DONORS=$4
GTF=$5
EXCL=$6
OUT=$7

time $AMBIMUX \
    --rna-bam $RNA_BAM \
    --vcf $VCF \
    --gtf $GTF \
    --peaks $PEAKS \
    --exclude $EXCL \
    --samples $DONORS \
    --rna-mapq 30 \
    --atac-mapq 30 \
    --out-min 100 \
    --bc-wl $WL_BCS \
    --out $OUT \
    --threads 50 \
    --verbose

    # --atac-bam $ATAC_BAM \

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
