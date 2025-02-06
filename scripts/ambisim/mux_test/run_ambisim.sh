#!/bin/bash
#$ -cwd
#$ -o logs/A01c_run_ambisim.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01c_run_ambisim
#$ -l h_data=2G,h_rt=4:00:00
#$ -pe shared 8

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

AMBISIM=/u/home/t/terencew/project-cluo/programs/ambisim/ambisim

BASEDIR=/u/home/t/terencew/project-cluo/igvf/pilot/multiome
AUTO=$BASEDIR/scripts/ambient/ambisim/misc/setup_autosome.py
CR_BASE=/u/project/cluo/Shared_Datasets/IGVF/202208_Pilot/10X_Multiome/cellranger/

PROJDIR=$1
SAMPLE=$2
N_DONORS=$3
DONORS=$4
VCF=$5

cd $PROJDIR

### shared
GTF=/u/home/t/terencew/project-cluo/reference/refdata-cellranger-arc-GRCh38-2020-A-2.0.0/genes/genes_autosome.gtf
PEAKS=${CR_BASE}/${SAMPLE}/outs/atac_peaks.bed
FASTA=/u/project/cluo/terencew/reference/hg38/fasta/hg38_autosomal_noclip.fa

### subset to autosome
echo 'subsetting to autosome'

INDIR=$PROJDIR/$SAMPLE
time python $AUTO $INDIR $GTF $PEAKS

### ambisim

CELL_TYPES=${INDIR}/cell_types.txt
GENE_PROBS=${INDIR}/autosome_gene_probs.txt
GENE_IDS=${INDIR}/autosome_gene_ids.txt
PEAK_PROBS=${INDIR}/autosome_peak_probs.txt
ATAC_PEAKS=${CR_BASE}/${SAMPLE}/outs/autosome_peaks.bed
SPL_PROBS=${INDIR}/spl_probs.txt

DROP_DATA_RAND=${INDIR}/drop_data_rand.txt
OUT=${INDIR}/fastq

time $AMBISIM \
    --gtf $GTF \
    --fasta $FASTA \
    --samples $DONORS \
    --cell-types $CELL_TYPES \
    --drop-file $DROP_DATA_RAND \
    --expr-prob $GENE_PROBS \
    --gene-ids $GENE_IDS \
    --mmrna-prob $SPL_PROBS \
    --peak-prob $PEAK_PROBS \
    --peaks $ATAC_PEAKS \
    --vcf $VCF \
    --seed 1 \
    --tx-basic \
    --verbose \
    --out $OUT

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
