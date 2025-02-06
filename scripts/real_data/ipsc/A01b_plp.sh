#!/bin/bash
#$ -cwd
#$ -o logs/A01c_plp.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01c_plp
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

TEMPLATE=/u/project/cluo/terencew/demux_benchmark/template_demux/
# VCF=/u/project/cluo/terencew/reference/cellsnp_db/hg38.AF5e2.possorted.chr_prefix.vcf.gz
VCF=/u/project/cluo/terencew/reference/cellsnp_db/hg38.AF5e2.possorted.chr_prefix.autosome.vcf.gz

SAMPLE=20220928-IGVF-D0
LIST=$PROJDIR/ambient/ambisim/cov_mux_test/txt/experiments.txt

# ID=1
ID=${SGE_TASK_ID}
EXP=$(head -${ID} $LIST | tail -1)
INDIR=$PROJDIR/ambient/ambisim/cov_mux_test/$EXP
cd $INDIR

N_DONORS=${EXP%_*}

CR_BASE=$INDIR/cr_arc
DEMUX_DIR=$INDIR/demux

GEX_BAM=$DEMUX_DIR/autosome_bam/gex/${SAMPLE}.reheader.bam
ATAC_BAM=$DEMUX_DIR/autosome_bam/atac/${SAMPLE}.reheader.bam

BARCODES=${CR_BASE}/$SAMPLE/outs/filtered_feature_bc_matrix/barcodes.tsv.gz

POPSCLE_GEX=$DEMUX_DIR/demuxlet/gex/
POPSCLE_ATAC=$DEMUX_DIR/demuxlet/atac/
qsub $TEMPLATE/popscle_gex.sh $GEX_BAM $BARCODES $SAMPLE $VCF $POPSCLE_GEX
qsub $TEMPLATE/popscle_atac.sh $ATAC_BAM $BARCODES $SAMPLE $VCF $POPSCLE_ATAC

CELLSNP_GEX=$DEMUX_DIR/cellsnp/gex/$SAMPLE/
CELLSNP_ATAC=$DEMUX_DIR/cellsnp/atac/$SAMPLE/
qsub $TEMPLATE/cellsnp_gex.sh $GEX_BAM $BARCODES $VCF $CELLSNP_GEX
qsub $TEMPLATE/cellsnp_atac.sh $ATAC_BAM $BARCODES $VCF $CELLSNP_ATAC


GENO_VCF=$PROJDIR/ambient/ambisim/mux_test/vcf/${N_DONORS}_donors_000.vcf.gz
VARCON_GEX=$DEMUX_DIR/varcon_cellsnp/gex/$SAMPLE/
VARCON_ATAC=$DEMUX_DIR/varcon_cellsnp/atac/$SAMPLE/
qsub $TEMPLATE/varcon_cellsnp_gex.sh $GEX_BAM $BARCODES $GENO_VCF $VARCON_GEX
qsub $TEMPLATE/varcon_cellsnp_atac.sh $ATAC_BAM $BARCODES $GENO_VCF $VARCON_ATAC

### scsplit

SCSPLIT_GEX=$DEMUX_DIR/scsplit/gex/$SAMPLE/
qsub $TEMPLATE/freebayes.sh $GEX_BAM $SCSPLIT_GEX $SAMPLE

SCSPLIT_ATAC=$DEMUX_DIR/scsplit/atac/$SAMPLE/
qsub $TEMPLATE/freebayes.sh $ATAC_BAM $SCSPLIT_ATAC $SAMPLE

SCAVENGERS_ATAC=$DEMUX_DIR/scavengers/atac/$SAMPLE/
qsub $TEMPLATE/scavengers_matrix_cellsnp.sh $ATAC_BAM $BARCODES $SCAVENGERS_ATAC

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
