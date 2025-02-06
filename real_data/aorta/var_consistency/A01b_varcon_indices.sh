#!/bin/bash
#$ -cwd
#$ -o logs/A01b_varcon_indices.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01b_varcon_indices
#$ -l h_data=2G,h_rt=12:00:00
#$ -pe shared 8
#$ -t 1-2:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/demux_benchmark/adelus_2023
cd $PROJDIR

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/

SAMPLE=20220928-IGVF-D0

# ID=1
ID=${SGE_TASK_ID}
SAMPLES=$PROJDIR/txt/samples.txt
SAMPLE=$(head -${ID} $SAMPLES | tail -1)

if [ "$SAMPLE" == "pooled_endMT_1" ] || \
   [ "$SAMPLE" == "pooled_endMT_2" ] || \
   [ "$SAMPLE" == "pooled_endMT_3" ] ; then
  GEX_VCF=$PROJDIR/vcf/MT1-3.090.vcf.gz
  ATAC_VCF=$PROJDIR/vcf/MT1-3.090.vcf.gz
  DONORS=$PROJDIR/txt/MT1-3_donors.txt
  N_DONORS=6
fi

if [ "$SAMPLE" == "pooled_endMT_4" ]; then
  GEX_VCF=$PROJDIR/vcf/MT4.090.vcf.gz
  ATAC_VCF=$PROJDIR/vcf/MT4.090.vcf.gz
  DONORS=$PROJDIR/txt/MT4_donors.txt
  N_DONORS=6
fi

if [ "$SAMPLE" == "pooled_endMT_5" ]; then
  GEX_VCF=$PROJDIR/vcf/MT5.090.vcf.gz
  ATAC_VCF=$PROJDIR/vcf/MT5.090.vcf.gz
  DONORS=$PROJDIR/txt/MT5_donors.txt
  N_DONORS=5
fi

INDIR=$PROJDIR/demux/regular
cd $INDIR

VARCON=/u/home/t/terencew/project-cluo/programs/var_consistency/02_get_con_indices.py

GEX_INDIR=$INDIR/var_consistency/gex/$SAMPLE/consistency/
GEX_OUTDIR=$INDIR/var_consistency/gex/$SAMPLE/dict/

time python $VARCON -i $GEX_INDIR -d $DONORS \
      -o $GEX_OUTDIR -t 40

ATAC_INDIR=$INDIR/var_consistency/atac/$SAMPLE/consistency/
ATAC_OUTDIR=$INDIR/var_consistency/atac/$SAMPLE/dict/

time python $VARCON -i $ATAC_INDIR -d $DONORS \
      -o $ATAC_OUTDIR -t 40

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
