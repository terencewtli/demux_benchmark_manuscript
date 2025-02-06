#!/bin/bash
#$ -cwd
#$ -o logs/A02c_vireo.$JOB_ID
#$ -j y
#$ -N A02c_vireo
#$ -l h_data=2G,h_rt=8:00:00
#$ -pe shared 10

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

N_DONORS=$1
IN=$2
OUT=$3

echo $OUT

time vireo -c $IN -t GT \
  -p 50 -N ${N_DONORS} -o $OUT

#  -p 50 -N ${N_DONORS} -o $OUT --callAmbientRNAs

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
