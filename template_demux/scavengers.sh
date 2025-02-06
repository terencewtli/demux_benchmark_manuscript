#!/bin/bash
#$ -cwd
#$ -o logs/A02j_scavengers.$JOB_ID
#$ -j y
#$ -N A02j_scavengers
#$ -l h_data=2G,h_rt=12:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

STRELKA_CONFIG=/u/project/cluo/terencew/programs/scAVENGERS/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaGermlineWorkflow.py
VARTRIX=/u/home/t/terencew/project-cluo/programs/vartrix
CLUSTER=/u/home/t/terencew/project-cluo/programs/scAVENGERS/scripts/cluster.py
TROUBLET=/u/home/t/terencew/project-cluo/programs/scAVENGERS/troublet

FASTA=/u/project/cluo/terencew/reference/hg38/fasta/hg38_autosomal.fa

### params for doublet
DBL_PRIOR=0.5
DBL_THRESH=0.9
SNG_THRESH=0.9

INDIR=$1
BAM=$2
BARCODES=$3
SAMPLE=$4
VCF=$5
N_DONORS=$6

####

echo 'strelka'
OUTDIR=$INDIR/scavengers/atac/${SAMPLE}/

time $STRELKA_CONFIG --bam $BAM --referenceFasta $FASTA \
   --runDir $OUTDIR

STRELKA=$OUTDIR/runWorkflow.py

time $STRELKA -m local -j 50

###

echo 'make matrix'
ALT=$INDIR/scavengers/atac/${SAMPLE}/alt.mtx
REF=$INDIR/scavengers/atac/${SAMPLE}/ref.mtx
MAPQ=30

time $VARTRIX -b $BAM -v $VCF --fasta $FASTA \
    -c $BARCODES --out-matrix $ALT \
    --ref-matrix $REF --mapq $MAPQ \
    --scoring-method coverage --threads 50

###

echo 'make clusters'
CLUSTER_OUT=$INDIR/scavengers/atac/${SAMPLE}/

time $CLUSTER -r $REF -a $ALT -o $CLUSTER_OUT \
    -k $N_DONORS --err_rate 0.001 \
    --stop_criterion 0.1 \
    -b $BARCODES \
    --max_iter 1000 --threads 10

###

echo 'call doublets'

CLUSTERS=$INDIR/scavengers/${SAMPLE}/clusters.tsv
OUT=$INDIR/scavengers/${SAMPLE}/clusters.final.tsv

time $TROUBLET --refs $REF --alts $ALT \
    --clusters $CLUSTERS \
    --doublet_prior $DBL_PRIOR \
    --doublet_threshold $DBL_THRESH \
    --singlet_threshold $SNG_THRESH \
    > $OUT

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
