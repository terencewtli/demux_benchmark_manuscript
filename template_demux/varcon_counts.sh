#!/bin/bash
#$ -cwd
#$ -o logs/A03b_counts_gex.$JOB_ID
#$ -j y
#$ -N A03b_counts_gex
#$ -l h_data=2G,h_rt=4:00:00
#$ -pe shared 2

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

BASEDIR=/u/home/t/terencew/project-cluo/igvf/pilot/multiome/
EXTRACT=$BASEDIR/scripts/ambient/var_consistency/02b_new_counts.py

VARCON_DIR=$1
CELLSNP_DIR=$2
DONORS=$3
START=$4

INTERVAL=200

# COVS=(0 10 20 30 40 50)
COVS=(40 20 0)
time for COV in ${COVS[@]};
do
  time python $EXTRACT $VARCON_DIR $CELLSNP_DIR $DONORS $COV $START $INTERVAL
done

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
