#!/bin/bash
#$ -cwd
#$ -o logs/A02j_scavengers_matrix.$JOB_ID
#$ -j y
#$ -N A02j_scavengers_matrix
#$ -l h_data=2G,h_rt=24:00:00
#$ -pe shared 12

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

STRELKA_CONFIG=/u/project/cluo/terencew/programs/scAVENGERS/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaGermlineWorkflow.py
VARTRIX=/u/home/t/terencew/project-cluo/programs/vartrix
FASTA=/u/project/cluo/terencew/reference/hg38/fasta/hg38_autosomal.fa

BAM=$1
BARCODES=$2
OUTDIR=$3

####

echo 'strelka'

time $STRELKA_CONFIG --bam $BAM --referenceFasta $FASTA \
   --runDir $OUTDIR

STRELKA=$OUTDIR/runWorkflow.py

time $STRELKA -m local -j 50

###

VCF=$OUTDIR/results/variants/variants.vcf.gz

echo 'make matrix'
ALT=$OUTDIR/alt.mtx
REF=$OUTDIR/ref.mtx
MAPQ=30

time $VARTRIX -b $BAM -v $VCF --fasta $FASTA \
    -c $BARCODES --out-matrix $ALT \
    --ref-matrix $REF --mapq $MAPQ \
    --scoring-method coverage --threads 50

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
