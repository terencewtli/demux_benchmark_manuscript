#!/bin/bash
#$ -cwd
#$ -o logs/A02d_vireo.$JOB_ID
#$ -j y
#$ -N A02d_vireo
#$ -l h_data=2G,h_rt=8:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

VCF=$1
N_DONORS=$2
IN=$3
OUT=$4

echo $OUT

time vireo -c $IN -t GT -d $VCF \
   -p 50 -N ${N_DONORS} -o $OUT --callAmbientRNAs

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
