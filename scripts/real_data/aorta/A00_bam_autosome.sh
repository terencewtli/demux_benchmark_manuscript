#!/bin/bash
#$ -cwd
#$ -o logs/A00_bam_auto.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A00_bam_auto
#$ -l h_data=1G,h_rt=1:00:00
#$ -pe shared 1
#$ -t 1-7:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/demux_benchmark/adelus_2023
cd $PROJDIR

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/

ID=${SGE_TASK_ID}
SAMPLE=$(head -${ID} $PROJDIR/txt/samples.txt | tail -1)

CR_BASE=$PROJDIR/mapping/cr_arc/

INDIR=$PROJDIR/demux/regular/
cd $INDIR

GEX_BAM=${CR_BASE}/${SAMPLE}/outs/gex_possorted_bam.bam
ATAC_BAM=${CR_BASE}/${SAMPLE}/outs/atac_possorted_bam.bam

GEX_HEADER=$PROJDIR/bam/header/${SAMPLE}/gex_autosome_header.sam
ATAC_HEADER=$PROJDIR/bam/header/${SAMPLE}/atac_autosome_header.sam

GEX_OUT=$INDIR/autosome_bam/gex/${SAMPLE}.bam
ATAC_OUT=$INDIR/autosome_bam/atac/${SAMPLE}.bam

qsub $TEMPLATE/autosome_bam.sh $GEX_BAM $ATAC_BAM $GEX_HEADER $ATAC_HEADER $GEX_OUT $ATAC_OUT

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
