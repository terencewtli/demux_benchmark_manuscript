#!/bin/bash
#$ -cwd
#$ -o logs/A01a_setup_drop_datf.$JOB_ID
#$ -j y
#$ -N A01a_setup_drop_datf
#$ -l h_data=2G,h_rt=2:00:00,highp
#$ -pe shared 2

source ~/.bashrc

PROJDIR=$1
SAMPLE=$2
OUTDIR=$3
# CR_BASE=/u/project/cluo/Shared_Datasets/IGVF/202208_Pilot/10X_Multiome/cellranger/
CR_BASE=$4
PROP=$5
DBL=$6

cd $PROJDIR

# shared
AMB_DIR=/u/home/t/terencew/project-cluo/programs/ambisim/utils/
RNA_WL=/u/home/t/terencew/project-cluo/reference/barcodes/rna_cr_arc-v1.txt
ATAC_WL=/u/home/t/terencew/project-cluo/reference/barcodes/atac_cr_arc-v1.txt

OUTDIR=$PROJDIR/$SAMPLE

echo 'get top barcodes'
TOP=${AMB_DIR}/get_top_n_bc.R
COUNTS_DIR=${CR_BASE}/${SAMPLE}/outs/filtered_feature_bc_matrix
N_BARCODES=9000
OUT=${OUTDIR}/top_${N_BARCODES}_bcs.txt
time Rscript $TOP $COUNTS_DIR $N_BARCODES $OUT

echo 'probs from data'
PROBS=${AMB_DIR}/probs_from_data.R
COUNTS_DIR=${CR_BASE}/${SAMPLE}/outs/raw_feature_bc_matrix
FLT_BC=${OUTDIR}/top_${N_BARCODES}_bcs.txt
time Rscript $PROBS $COUNTS_DIR $FLT_BC $OUTDIR

echo 'sample props'
GET_PROPS=${AMB_DIR}/mk_sam_props.R
SAMPLE_IDS=$BASEDIR/txt/donors.txt
OUT=$OUTDIR/sample_freq.txt
time Rscript $GET_PROPS $SAMPLE_IDS $OUT

echo 'make drop dataframe'
### make drop dataframe
SAMPLE_FREQ=$OUTDIR/sample_freq.txt
CT_FREQ=$OUTDIR/ct_freq.txt
OUT=$OUTDIR/drop_data_rand.txt

DROP=$BASEDIR/scripts/ambient/ambisim/template_demux/mk_drop_datf.R

SEED=$RANDOM
echo "seed $SEED for ${PROP}_${DBL}" >> $BASEDIR/txt/seeds.txt
time Rscript $DROP $RNA_WL $ATAC_WL \
  $SAMPLE_FREQ $CT_FREQ $SEED $OUT $PROP $DBL
