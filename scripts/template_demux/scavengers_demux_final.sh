#!/bin/bash
#$ -cwd
#$ -o logs/A02j_scavengers_demux.$JOB_ID
#$ -j y
#$ -N A02j_scavengers_demux
#$ -l h_data=300G,h_rt=3:00:00

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate scavengers

CLUSTER=/u/home/t/terencew/project-cluo/programs/scAVENGERS/scripts/cluster.py
TROUBLET=/u/home/t/terencew/project-cluo/programs/scAVENGERS/troublet

### params for doublet
DBL_PRIOR=0.5
DBL_THRESH=0.9
SNG_THRESH=0.9

### indir contains REF/ALT
### clustesr are output here
INDIR=$1
OUTDIR=$2
BARCODES=$3
N_DONORS=$4

REF=$INDIR/ref.mtx
ALT=$INDIR/alt.mtx

CLUSTERS=$OUTDIR/clusters.tsv
OUT=$OUTDIR/clusters.final.tsv

time $TROUBLET --refs $REF --alts $ALT \
    --clusters $CLUSTERS \
    --doublet_prior $DBL_PRIOR \
    --doublet_threshold $DBL_THRESH \
    --singlet_threshold $SNG_THRESH \
    > $OUT

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
