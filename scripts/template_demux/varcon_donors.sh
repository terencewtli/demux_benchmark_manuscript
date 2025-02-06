#!/bin/bash
#$ -cwd
#$ -o logs/A03a_run_varcon.$JOB_ID
#$ -j y
#$ -N A03a_run_varcon
#$ -l h_data=8G,h_rt=8:00:00
#$ -pe shared 2

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

BASEDIR=/u/project/cluo/terencew/igvf/pilot/multiome/
VARCON=$BASEDIR/scripts/ambient/var_consistency/01_new_varcon.py

CELLSNP_DIR=$1
VCF=$2
DONORS=$3
OUTDIR=$4

time python $VARCON $CELLSNP_DIR \
    $VCF $DONORS $OUTDIR

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
