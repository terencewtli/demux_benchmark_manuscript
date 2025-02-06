#!/bin/bash
#$ -cwd
#$ -o logs/A01a_setup_drop_datf.$JOB_ID
#$ -j y
#$ -N A01a_setup_drop_datf
#$ -l h_data=2G,h_rt=2:00:00,highp
#$ -pe shared 2

source ~/.bashrc

BASEDIR=/u/home/t/terencew/project-cluo/igvf/pilot/multiome

PROJDIR=$1
SAMPLE=$2
N_DONORS=$3
DONORS=$4
PROP=$5
DOUB=$6

time bash $SETUP_DROP $INDIR $SAMPLE \
    $N_DONORS $DONORS $PROP $DOUB

cd $PROJDIR

# shared
CR_BASE=/u/project/cluo/Shared_Datasets/IGVF/202208_Pilot/10X_Multiome/cellranger/
AMB_DIR=/u/home/t/terencew/project-cluo/programs/ambisim/utils/
RNA_WL=/u/home/t/terencew/project-cluo/reference/barcodes/rna_cr_arc-v1.txt
ATAC_WL=/u/home/t/terencew/project-cluo/reference/barcodes/atac_cr_arc-v1.txt
DROP=/u/project/cluo/terencew/igvf/pilot/multiome/scripts/ambient/ambisim/run_cov_doub_test/mk_drop_datf.R

OUTDIR=$PROJDIR/$SAMPLE

echo 'get top barcodes'
### get top 9k barcodes
TOP=${AMB_DIR}/get_top_n_bc.R
COUNTS_DIR=${CR_BASE}/${SAMPLE}/outs/filtered_feature_bc_matrix
N_BARCODES=9000
OUT=${OUTDIR}/top_${N_BARCODES}_bcs.txt
Rscript $TOP $COUNTS_DIR $N_BARCODES $OUT

echo 'probs from data'
### get probabilities
PROBS=${AMB_DIR}/probs_from_data.R
COUNTS_DIR=${CR_BASE}/${SAMPLE}/outs/raw_feature_bc_matrix
FLT_BC=${OUTDIR}/top_${N_BARCODES}_bcs.txt
Rscript $PROBS $COUNTS_DIR $FLT_BC $OUTDIR

echo 'sample props'
### get sample props
GET_PROPS=${AMB_DIR}/mk_sam_props.R
OUT=$OUTDIR/sample_freq.txt

Rscript $GET_PROPS $DONORS $OUT

echo 'make drop dataframe'
### make drop dataframe
SAMPLE_FREQ=$OUTDIR/sample_freq.txt
CT_FREQ=$OUTDIR/ct_freq.txt
OUT=$OUTDIR/drop_data_rand.txt

SEED=1
time Rscript $DROP $RNA_WL $ATAC_WL \
  $SAMPLE_FREQ $CT_FREQ $SEED $OUT $PROP $DOUB
