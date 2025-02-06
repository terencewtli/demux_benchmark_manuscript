#!/bin/bash
#$ -cwd
#$ -o logs/A02j_scavengers_demux.$JOB_ID
#$ -j y
#$ -N A02j_scavengers_demux
#$ -l h_data=4G,h_rt=18:00:00
#$ -pe shared 10

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate scavengers

# CLUSTER=/u/home/t/terencew/project-cluo/programs/scAVENGERS/scripts/cluster.py
CLUSTER=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/scavengers_cluster.py
TROUBLET=/u/home/t/terencew/project-cluo/programs/scAVENGERS/troublet

### params for doublet
DBL_PRIOR=0.5
DBL_THRESH=0.9
SNG_THRESH=0.9

### indir contains REF/ALT
### clusters are output here
INDIR=$1
OUTDIR=$2
BARCODES=$3
N_DONORS=$4

####
echo 'make clusters'

REF=$INDIR/cellSNP.tag.REF.mtx
ALT=$INDIR/cellSNP.tag.AD.mtx

time $CLUSTER -r $REF -a $ALT -o $OUTDIR \
    -k $N_DONORS --err_rate 0.001 \
    --stop_criterion 0.1 \
    -b $BARCODES \
    --max_iter 1000 --threads 8

###

echo 'call doublets'

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
