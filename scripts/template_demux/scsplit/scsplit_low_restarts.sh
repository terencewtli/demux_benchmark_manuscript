#!/bin/bash
#$ -cwd
#$ -o logs/A02k_scsplit.$JOB_ID
#$ -j y
#$ -N A02k_scsplit
#$ -l h_data=8G,h_rt=16:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

TEMPLATE=/u/project/cluo/terencew/demux_benchmark/template_demux
SCSPLIT=$TEMPLATE/scsplit/no_alleles_scSplit

INDIR=$1
OUTDIR=$2
VCF=$3
CLUSTERS=$4

### bruh...
RESTARTS=1

REF=$INDIR/cellSNP.tag.REF.mtx
ALT=$INDIR/cellSNP.tag.AD.mtx
BARCODES=$INDIR/cellSNP.samples.tsv
SNPS=$INDIR/scsplit.snps.txt

time $SCSPLIT run -r $REF -a $ALT \
  -n $CLUSTERS -o $OUTDIR -e $RESTARTS \
  -b $BARCODES -z $SNPS -v $VCF

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
