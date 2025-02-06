#!/bin/bash
#$ -cwd
#$ -o logs/A01d_call_demux.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01d_call_demux
#$ -l h_data=1G,h_rt=1:00:00
#$ -pe shared 1
#$ -t 1-28:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/igvf/pilot/multiome
cd $PROJDIR

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/

SAMPLE=20220928-IGVF-D0
LIST=$PROJDIR/ambient/ambisim/cov_mux_test/txt/experiments.txt

# ID=1
ID=${SGE_TASK_ID}
EXP=$(head -${ID} $LIST | tail -1)
INDIR=$PROJDIR/ambient/ambisim/cov_mux_test/$EXP/
cd $INDIR

N_DONORS=${EXP%_*}
DONORS=$PROJDIR/ambient/ambisim/cov_mux_test/txt/${N_DONORS}_donors.txt

CR_BASE=$INDIR/cr_arc/
DEMUX_DIR=$INDIR/demux

# GEX_BAM=$DEMUX_DIR/autosome_bam/gex/${SAMPLE}.reheader.bam
# ATAC_BAM=$DEMUX_DIR/autosome_bam/atac/${SAMPLE}.reheader.bam

GEX_BAM=$CR_BASE/$SAMPLE/outs/gex_possorted_bam.bam
ATAC_BAM=$CR_BASE/$SAMPLE/outs/atac_possorted_bam.bam

BARCODES=${CR_BASE}/$SAMPLE/outs/filtered_feature_bc_matrix/barcodes.tsv.gz

# GEX_VCF=$PROJDIR/vcf/pilot_090.vcf.gz
# ATAC_VCF=$PROJDIR/vcf/pilot_090.vcf.gz

GEX_VCF=$PROJDIR/ambient/ambisim/mux_test/vcf/${N_DONORS}_donors_090.vcf.gz
ATAC_VCF=$PROJDIR/ambient/ambisim/mux_test/vcf/${N_DONORS}_donors_090.vcf.gz
DONORS=$PROJDIR/ambient/ambisim/cov_mux_test/txt/${N_DONORS}_donors_090.vcf.gz

GEX_DEMUXLET_PLP=$DEMUX_DIR/demuxlet/gex/${SAMPLE}.pileup
ATAC_DEMUXLET_PLP=$DEMUX_DIR/demuxlet/atac/${SAMPLE}.pileup

GEX_CELLSNP=$DEMUX_DIR/cellsnp/gex/${SAMPLE}/
ATAC_CELLSNP=$DEMUX_DIR/cellsnp/atac/${SAMPLE}/

GEX_SCSPLIT=$DEMUX_DIR/scsplit/gex/${SAMPLE}/cellsnp
ATAC_SCSPLIT=$DEMUX_DIR/scsplit/atac/${SAMPLE}/cellsnp

PEAKS=$CR_BASE/$SAMPLE/outs/atac_peaks.bed

WRAPPER=$TEMPLATE/call_demux.sh

bash $WRAPPER $DEMUX_DIR $SAMPLE $BARCODES \
    $GEX_BAM $ATAC_BAM \
    $GEX_VCF $ATAC_VCF \
    $N_DONORS $DONORS \
    $GEX_DEMUXLET_PLP $ATAC_DEMUXLET_PLP \
    $GEX_CELLSNP $ATAC_CELLSNP \
    $GEX_SCSPLIT $ATAC_SCSPLIT \
    $ATAC_SCAVENGERS \
    $PEAKS

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
