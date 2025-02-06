#!/bin/bash
#$ -cwd
#$ -o logs/A02i_demuxalot.$JOB_ID
#$ -j y
#$ -N A02i_demuxalot
#$ -l h_data=8G,h_rt=8:00:00
#$ -pe shared 6

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/
DEMUXALOT=$TEMPLATE/run_demuxalot.py

SAMPLE=$1
BARCODES=$2
BAM=$3
VCF=$4
DONORS=$5
OUT=$6

mkdir -p $OUT

time python $DEMUXALOT \
  $SAMPLE $BARCODES $BAM $VCF $DONORS $OUT

echo " "
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
