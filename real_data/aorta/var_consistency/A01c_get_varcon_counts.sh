#!/bin/bash
#$ -cwd
#$ -o logs/A01c_get_varcon_counts.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01c_get_varcon_counts
#$ -l h_data=2G,h_rt=12:00:00
#$ -pe shared 8
#$ -t 1-28:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/demux_benchmark/adelus_2023
cd $PROJDIR

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/

CR_BASE=$PROJDIR/mapping/cr_arc/

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

VARCON=/u/home/t/terencew/project-cluo/programs/var_consistency/03_count_varcon.py

COVS=(0 5 10 15 20)

GEX_INDIR=$INDIR/var_consistency/gex/$SAMPLE/consistency/
GEX_PKLDIR=$INDIR/var_consistency/gex/$SAMPLE/dict/

time for COV in ${COVS[@]};
do
    GEX_OUTDIR=$INDIR/var_consistency/atac/$SAMPLE/csv/cov_${COV}
    python $VARCON -i $GEX_INDIR -p $GEX_PKLDIR \
        -d $DONORS -o $GEX_OUTDIR -c $COV
done

COVS=(0 5 10 15 20)

ATAC_INDIR=$INDIR/var_consistency/atac/$SAMPLE/consistency/
ATAC_PKLDIR=$INDIR/var_consistency/atac/$SAMPLE/dict/

time for COV in ${COVS[@]};
do
    ATAC_OUTDIR=$INDIR/var_consistency/atac/$SAMPLE/csv/cov_${COV}
    python $VARCON -i $ATAC_INDIR -p $ATAC_PKLDIR \
        -d $DONORS -o $ATAC_OUTDIR -c $COV
done

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
