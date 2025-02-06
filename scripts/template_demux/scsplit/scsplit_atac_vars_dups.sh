#!/bin/bash
#$ -cwd
#$ -o logs/A01f_scsplit_preprocess_atac.$JOB_ID
#$ -j y
#$ -N A01f_scsplit_preprocess_atac
#$ -l h_data=8G,h_rt=24:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

FASTA_PY=/u/home/t/terencew/project-cluo/programs/freebayes/scripts/fasta_generate_regions.py

FBAYES_INDIR=/u/project/cluo/terencew/programs/freebayes/scripts/
export PATH=$FBAYES_INDIR:$PATH
FBAYES=$FBAYES_INDIR/freebayes-parallel

parallel --citation 2>/dev/null

FASTA=/u/project/cluo/terencew/reference/hg38/fasta/hg38_autosomal.fa

INDIR=$1
BAM=$2
BARCODES=$3
SAMPLE=$4

###
echo 'preprocess bam'

FILTERED_BAM=$INDIR/${SAMPLE}.filtered.bam
# time samtools view -@ 50 -S -b -q 10 -F 3844 $BAM > $FILTERED_BAM
# samtools index $FILTERED_BAM

###
echo 'umitools dedup'
RMDUP_BAM=$INDIR/${SAMPLE}.filtered.rmdup.bam
# time umi_tools dedup --ignore-umi --stdin=$FILTERED_BAM \
#     --stdout=$RMDUP_BAM

###
echo 'sort index'
FINAL_BAM=$INDIR/${SAMPLE}.final.bam
# time samtools sort -@ 50 -o $FINAL_BAM $RMDUP_BAM
# samtools index $FINAL_BAM

###
echo 'freebayes'
VARIANTS=$INDIR/${SAMPLE}.vcf

# time $FBAYES <($FASTA_PY $FASTA 100000) 50 \
#     -f $FASTA $FINAL_BAM > $VARIANTS

time $FBAYES <($FASTA_PY $FASTA 100000) 50 \
    -f $FASTA $BAM > $VARIANTS

###
echo 'filter variants'

FILTERED_VARS=$INDIR/${SAMPLE}.filtered.vcf.gz
time bcftools filter -Oz -i '%QUAL>30' $VARIANTS > $FILTERED_VARS
zcat $FILTERED_VARS > ${FILTERED_VARS%.gz}
tabix -p vcf $FILTERED_VARS

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
