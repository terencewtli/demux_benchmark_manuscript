#!/bin/bash
#$ -cwd
#$ -o logs/A04a_scdblfinder.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A04a_scdblfinder
#$ -l h_data=8G,h_rt=4:00:00
#$ -pe shared 2
#$ -t 1-3:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=$1
SAMPLE=$2

COUNTS=$PROJDIR/cr_arc/${SAMPLE}/outs/filtered_feature_bc_matrix.h5
OUTDIR=$PROJDIR/doublets/gex/${SAMPLE}/

DEMUXAFY=/u/project/cluo/terencew/programs/Demuxafy.sif
CMD=scDblFinder.R

time singularity exec $DEMUXAFY $CMD \
  -o $OUTDIR -t $COUNTS

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
