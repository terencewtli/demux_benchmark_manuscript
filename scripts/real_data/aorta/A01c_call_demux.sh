#!/bin/bash
#$ -cwd
#$ -o logs/A01c_call_demux.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01c_call_demux
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

CR_BASE=$PROJDIR/mapping/cr_arc/

ID=${SGE_TASK_ID}
SAMPLE=$(head -${ID} $PROJDIR/txt/samples.txt | tail -1)

if [ "$SAMPLE" == "ctrl6h" ] || \
   [ "$SAMPLE" == "il1b6h" ] ; then
  GEX_VCF=$PROJDIR/vcf/6H.090.vcf.gz
  ATAC_VCF=$PROJDIR/vcf/6H.090.vcf.gz
  DONORS=$PROJDIR/txt/donors.txt
  N_DONORS=6
fi

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

INDIR=$PROJDIR/demux/regular/
cd $INDIR

GEX_BAM=${CR_BASE}/$SAMPLE/outs/gex_possorted_bam.bam
ATAC_BAM=${CR_BASE}/$SAMPLE/outs/atac_possorted_bam.bam
BARCODES=${CR_BASE}/$SAMPLE/outs/filtered_feature_bc_matrix/barcodes.tsv.gz

POPSCLE_GEX=$PROJDIR/demux/regular/demuxlet/gex/${SAMPLE}.pileup
POPSCLE_ATAC=$PROJDIR/demux/regular/demuxlet/atac/${SAMPLE}.pileup
CELLSNP_GEX=$PROJDIR/demux/regular/cellsnp/gex/${SAMPLE}
CELLSNP_ATAC=$PROJDIR/demux/regular/cellsnp/atac/${SAMPLE}

time bash $TEMPLATE/call_demux.sh $INDIR $SAMPLE \
    $BARCODES $GEX_BAM $ATAC_BAM \
    $GEX_VCF $ATAC_VCF $N_DONORS $DONORS \
    $POPSCLE_GEX $POPSCLE_ATAC \
    $CELLSNP_GEX $CELLSNP_ATAC \

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
