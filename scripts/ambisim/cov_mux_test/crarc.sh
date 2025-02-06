#!/bin/bash
#$ -cwd
#$ -o logs/crarc.$JOB_ID
#$ -j y
#$ -N crarc
#$ -l h_data=2G,h_rt=14:00:00
#$ -pe shared 12

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

PROJDIR=$1
SAMPLE=$2

cd $PROJDIR

FASTQ_DIR=$PROJDIR/$SAMPLE

HEADER='fastqs,sample,library_type'
NAME=sim

REF=/u/project/cluo/terencew/reference/refdata-cellranger-arc-GRCh38-2020-A-2.0.0
CRARC=/u/project/cluo/terencew/programs/cellranger-arc-2.0.1/bin/cellranger-arc

RNA_FASTQ=${FASTQ_DIR}/fastq/RNA
ATAC_FASTQ=${FASTQ_DIR}/fastq/ATAC
RNA="$RNA_FASTQ,$NAME,Gene Expression"
ATAC="$ATAC_FASTQ,$NAME,Chromatin Accessibility"
OUT=${PROJDIR}/setup_crarc.csv
echo -e "$HEADER\n$RNA\n$ATAC" > $OUT

LIB=$OUT
mkdir -p ${PROJDIR}/cr_arc

cd cr_arc

time $CRARC count --id $SAMPLE \
  --reference ${REF} --libraries ${LIB} \
  --localcores=80 --localmem=40

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
