#!/bin/bash
#$ -cwd
#$ -o logs/A01a_varcon_counts.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01a_varcon_counts
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

VARCON=/u/home/t/terencew/project-cluo/programs/var_consistency/01_con_counts_multithread.py

INDIR=$PROJDIR/demux/regular

GEX_CELLSNP=$INDIR/demux/varcon_cellsnp/gex/$SAMPLE/
GEX_OUTDIR=$INDIR/demux/var_consistency/gex/$SAMPLE/consistency

time python $VARCON -c $GEX_CELLSNP \
    -i $GEX_VCF -d $DONORS -o $GEX_OUTDIR -t 40

ATAC_CELLSNP=$INDIR/demux/varcon_cellsnp/atac/$SAMPLE/
ATAC_OUTDIR=$INDIR/demux/var_consistency/atac/$SAMPLE/consistency

time python $VARCON -c $ATAC_CELLSNP \
    -i $ATAC_VCF -d $DONORS -o $ATAC_OUTDIR -t 40

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
