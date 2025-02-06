#!/bin/bash
#$ -cwd
#$ -o logs/A01b_call_pileup.$JOB_ID
#$ -j y
#$ -N A01b_call_pileup
#$ -l h_data=1G,h_rt=1:00:00
#$ -pe shared 1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/
### do I use this???
COMMON_VARS=/u/project/cluo/terencew/reference/cellsnp_db/hg38.AF5e2.possorted.chr_prefix.vcf.gz

INDIR=$1
SAMPLE=$2
BARCODES=$3
GEX_BAM=$4
ATAC_BAM=$5
GEX_VCF=$6
ATAC_VCF=$7

P_GEX_OUT=$INDIR/demuxlet/gex/
P_ATAC_OUT=$INDIR/demuxlet/atac/
# qsub $TEMPLATE/popscle_gex.sh $GEX_BAM $BARCODES $SAMPLE $GEX_VCF $P_GEX_OUT
# qsub $TEMPLATE/popscle_atac.sh $ATAC_BAM $BARCODES $SAMPLE $ATAC_VCF $P_ATAC_OUT

qsub $TEMPLATE/popscle_gex.sh $GEX_BAM $BARCODES $SAMPLE $COMMON_VARS $P_GEX_OUT
qsub $TEMPLATE/popscle_atac.sh $ATAC_BAM $BARCODES $SAMPLE $COMMON_VARS $P_ATAC_OUT


CS_GEX_OUT=$INDIR/cellsnp/gex/$SAMPLE
CS_ATAC_OUT=$INDIR/cellsnp/atac/$SAMPLE
# qsub $TEMPLATE/cellsnp_gex.sh $GEX_BAM $BARCODES $GEX_VCF $CS_GEX_OUT
# qsub $TEMPLATE/cellsnp_atac.sh $ATAC_BAM $BARCODES $ATAC_VCF $CS_ATAC_OUT

qsub $TEMPLATE/cellsnp_gex.sh $GEX_BAM $BARCODES $COMMON_VARS $CS_GEX_OUT
qsub $TEMPLATE/cellsnp_atac.sh $ATAC_BAM $BARCODES $COMMON_VARS $CS_ATAC_OUT

VC_CS_GEX_OUT=$INDIR/varcon_cellsnp/gex/$SAMPLE
VC_CS_ATAC_OUT=$INDIR/varcon_cellsnp/atac/$SAMPLE
qsub $TEMPLATE/varcon_cellsnp_gex.sh $GEX_BAM $BARCODES $GEX_VCF $VC_CS_GEX_OUT
qsub $TEMPLATE/varcon_cellsnp_atac.sh $ATAC_BAM $BARCODES $ATAC_VCF $VC_CS_ATAC_OUT

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
