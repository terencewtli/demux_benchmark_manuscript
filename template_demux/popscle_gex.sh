#!/bin/bash
#$ -cwd
#$ -o logs/A01a_popscle_gex.$JOB_ID
#$ -j y
#$ -N A01a_popscle_gex
#$ -l h_data=8G,h_rt=16:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

TEMPLATE=/u/project/cluo/terencew/demux_benchmark/template_demux/
FILTER=$TEMPLATE/filter_bam_file_for_popscle_dsc_pileup.sh
SORT=$TEMPLATE/sort_vcf_same_as_bam.sh
POPSCLE=/u/project/cluo/terencew/programs/popscle/bin/popscle

BAM=$1
BARCODES=$2
SAMPLE=$3
VCF=$4
INDIR=$5

### filter
OUT_BAM=$INDIR/${SAMPLE}.bam
time bash $FILTER $BAM $BARCODES $VCF $OUT_BAM

### sort
TMP_VCF=$(basename $VCF)
OUT_VCF=${INDIR}/${SAMPLE}_${TMP_VCF}
time $SORT $BAM $VCF > $OUT_VCF

echo 'pileup gex'
PILEUP=${INDIR}/${SAMPLE}.pileup

time $POPSCLE dsc-pileup --sam $OUT_BAM --vcf ${OUT_VCF} \
  --out $PILEUP

echo " "
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
