#!/bin/bash
#$ -cwd
#$ -o logs/A01b_autosome_bam.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01b_autosome_bam
#$ -l h_data=1G,h_rt=1:00:00
#$ -pe shared 1
#$ -t 1-16:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/igvf/pilot/multiome
cd $PROJDIR

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/

SAMPLE=20220928-IGVF-D0
LIST=$PROJDIR/ambient/ambisim/cov_doub_test/txt/experiments.txt

# ID=1
ID=${SGE_TASK_ID}
EXP=$(head -${ID} $LIST | tail -1)

INDIR=$PROJDIR/ambient/ambisim/cov_doub_test/$EXP
cd $INDIR

CR_BASE=$INDIR/cr_arc/

GEX_BAM=${CR_BASE}/${SAMPLE}/outs/gex_possorted_bam.bam
ATAC_BAM=${CR_BASE}/${SAMPLE}/outs/atac_possorted_bam.bam

GEX_HEADER=$PROJDIR/ambient/ambisim/cov_doub_test/header/auto_gex_header.sam
ATAC_HEADER=$PROJDIR/ambient/ambisim/cov_doub_test/header/auto_atac_header.sam

GEX_OUT=$INDIR/demux/autosome_bam/gex/${SAMPLE}.bam
ATAC_OUT=$INDIR/demux/autosome_bam/atac/${SAMPLE}.bam

qsub $TEMPLATE/autosome_bam.sh $GEX_BAM $ATAC_BAM $GEX_HEADER $ATAC_HEADER $GEX_OUT $ATAC_OUT

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
