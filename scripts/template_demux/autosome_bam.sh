#!/bin/bash
#$ -cwd
#$ -o logs/A00_bam_autosome.$JOB_ID
#$ -j y
#$ -N A00_bam_autosome
#$ -l h_data=4G,h_rt=12:00:00
#$ -pe shared 12

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

RNA_BAM=$1
ATAC_BAM=$2
RNA_HEADER=$3
ATAC_HEADER=$4
RNA_OUT=$5
ATAC_OUT=$6

RNA_FINAL=${RNA_OUT%.bam}.reheader.bam
ATAC_FINAL=${ATAC_OUT%.bam}.reheader.bam

### subset to autosome bam
REGIONS="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22"

echo 'bam gex'
time samtools view --threads 50 -b \
  $RNA_BAM $REGIONS > $RNA_OUT
time samtools reheader $RNA_HEADER $RNA_OUT > $RNA_FINAL
samtools index $RNA_FINAL

### idk why but I need to get rid of PE reads coming from different chroms?????
ATAC_SAM=${ATAC_OUT%.bam}.sam
echo 'bam atac'
time samtools view --threads 50 \
  $ATAC_BAM $REGIONS | awk '$7 ~ /=/' > $ATAC_SAM

TMP_ATAC_SAM=${ATAC_SAM%.sam}.tmp.sam
{ cat $ATAC_HEADER; cat $ATAC_SAM; } > $TMP_ATAC_SAM

time samtools view -h -b --threads 50 $TMP_ATAC_SAM > $ATAC_FINAL
samtools index $ATAC_FINAL

### just keep final reheadered bams
rm -f $RNA_OUT $ATAC_OUT
rm -f ${ATAC_OUT%.bam}.*sam

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
