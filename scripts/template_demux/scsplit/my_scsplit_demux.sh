#!/bin/bash
#$ -cwd
#$ -N A02n_scsplit_demux
#$ -l h_data=4G,h_rt=12:00:00
#$ -pe shared 4

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

SCSPLIT=/u/project/cluo/terencew/demux_benchmark/template_demux/scsplit/my_scSplit

REF=$1
ALT=$2
OUT=$3
CLUSTERS=$4

time $SCSPLIT count -r $REF -a $ALT \
  -n $CLUSTERS -o $OUT -e $RESTARTS -d

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
