#!/bin/bash
#$ -cwd
#$ -o logs/A01c_call_demux.$JOB_ID
#$ -j y
#$ -N A01c_call_demux
#$ -l h_data=1G,h_rt=1:00:00
#$ -pe shared 1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/

INDIR=$1
SAMPLE=$2
BARCODES=$3
GEX_BAM=$4
ATAC_BAM=$5
GEX_VCF=$6
ATAC_VCF=$7
N_DONORS=$8
DONORS=$9

### pileup specific
DEMUXLET_GEX=${10}
DEMUXLET_ATAC=${11}
CELLSNP_GEX=${12}
CELLSNP_ATAC=${13}
SCSPLIT_GEX=${14}
SCSPLIT_ATAC=${15}

GEX_DEMUXLET=$INDIR/demuxlet/gex/$SAMPLE
ATAC_DEMUXLET=$INDIR/demuxlet/atac/$SAMPLE
qsub $TEMPLATE/demuxlet.sh $BARCODES $GEX_VCF $DEMUXLET_GEX $GEX_DEMUXLET
qsub $TEMPLATE/demuxlet.sh $BARCODES $ATAC_VCF $DEMUXLET_ATAC $ATAC_DEMUXLET

### vireo
GEX_VIREO=$INDIR/vireo/gex/${SAMPLE}/
ATAC_VIREO=$INDIR/vireo/atac/${SAMPLE}/
qsub $TEMPLATE/vireo.sh $GEX_VCF $N_DONORS $CELLSNP_GEX $GEX_VIREO
qsub $TEMPLATE/vireo.sh $ATAC_VCF $N_DONORS $CELLSNP_ATAC $ATAC_VIREO

### scsplit
GEX_SCSPLIT=$INDIR/scsplit/gex/$SAMPLE
ATAC_SCSPLIT=$INDIR/scsplit/atac/$SAMPLE
qsub $TEMPLATE/scsplit.sh $SCSPLIT_GEX $GEX_SCSPLIT $GEX_VCF $N_DONORS
qsub $TEMPLATE/scsplit.sh $SCSPLIT_ATAC $ATAC_SCSPLIT $ATAC_VCF $N_DONORS

### souporcell
GEX_SOUP=$INDIR/souporcell/gex/${SAMPLE}/
ATAC_SOUP=$INDIR/souporcell/atac/${SAMPLE}/
qsub $TEMPLATE/souporcell_gex.sh $BARCODES $GEX_BAM $N_DONORS ${GEX_VCF%.gz} $GEX_SOUP
qsub $TEMPLATE/souporcell_atac.sh $BARCODES $ATAC_BAM $N_DONORS ${ATAC_VCF%.gz} $ATAC_SOUP

### demuxalot
DEMUXALOT_OUT=$INDIR/demuxalot/gex/${SAMPLE}/
mkdir -p $DEMUXALOT_OUT
qsub $TEMPLATE/demuxalot.sh $SAMPLE $BARCODES $GEX_BAM $GEX_VCF $DONORS $DEMUXALOT_OUT

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
