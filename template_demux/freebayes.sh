#!/bin/bash
#$ -cwd
#$ -o logs/A01g_freebayes.$JOB_ID
#$ -j y
#$ -N A01g_freebayes
#$ -l h_data=4G,h_rt=24:00:00
#$ -pe shared 12

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

FBAYES_INDIR=/u/project/cluo/terencew/programs/freebayes/scripts/
export PATH=$FBAYES_INDIR:$PATH
FBAYES=$FBAYES_INDIR/freebayes-parallel
FASTA_PY=$FBAYES_INDIR/fasta_generate_regions.py

parallel --citation 2>/dev/null
FASTA=/u/project/cluo/terencew/reference/hg38/fasta/hg38_autosomal.fa

BAM=$1
OUTDIR=$2
SAMPLE=$3

VARIANTS=$OUTDIR/${SAMPLE}.vcf
FILTERED_VARS=$OUTDIR/${SAMPLE}.filtered.vcf.gz

time $FBAYES <($FASTA_PY $FASTA 100000) 100 \
    -f $FASTA $BAM > $VARIANTS

bcftools filter -Oz -i '%QUAL>30' $VARIANTS > $FILTERED_VARS
zcat $FILTERED_VARS > ${FILTERED_VARS%.gz}
tabix -p vcf $FILTERED_VARS

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
