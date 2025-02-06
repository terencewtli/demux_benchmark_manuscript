#!/bin/bash
#$ -cwd
#$ -o logs/cellbender.$JOB_ID
#$ -j y
#$ -N cellbender
#$ -l h_data=8G,h_rt=24:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate cellbender

INPUT=$1
DROPS=$2
EXPECTED=$3
OUT=$4
TMP_DIR=$5

cd $TMP_DIR

time cellbender remove-background \
     --total-droplets-included $DROPS \
     --expected-cells $EXPECTED \
     --input $INPUT \
     --epochs 20 \
     --cpu-threads 20 \
     --output $OUT

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
