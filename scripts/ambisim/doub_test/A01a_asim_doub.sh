#!/bin/bash
#$ -cwd
#$ -o logs/A01a_run_wrapper.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01a_run_wrapper
#$ -l h_data=4G,h_rt=8:00:00
#$ -pe shared 12
#$ -t 1-16:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/igvf/pilot/multiome
cd $PROJDIR

SAMPLE=20220928-IGVF-D0
VCF=$PROJDIR/vcf/pilot_000.vcf.gz
DONORS=$PROJDIR/txt/donors.txt
N_DONORS=4

TEMPLATE=$PROJDIR/scripts/ambient/ambisim/run_cov_doub_test/

SETUP_DROP=$TEMPLATE/setup_drop.sh
AMBISIM=$TEMPLATE/run_ambisim.sh
CR_ARC=$TEMPLATE/crarc.sh

LIST=$PROJDIR/ambient/ambisim/cov_doub_test/txt/experiments.txt

# ID=1
ID=${SGE_TASK_ID}
CONFIG=$(head -${ID} $LIST | tail -1)

PROP=${CONFIG%_*}
DOUB=${CONFIG#*_}

echo $CONFIG

INDIR=$PROJDIR/ambient/ambisim/cov_doub_test/$CONFIG

### spawn the logs in each parents' directory
cd $INDIR
### setup for ambisim
time bash $SETUP_DROP $INDIR $SAMPLE \
    $N_DONORS $DONORS $PROP $DOUB
### run ambisim
time bash $AMBISIM $INDIR $SAMPLE $N_DONORS $DONORS $VCF
### run cr_arc
qsub $CR_ARC $INDIR $SAMPLE
cd $PROJDIR

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
