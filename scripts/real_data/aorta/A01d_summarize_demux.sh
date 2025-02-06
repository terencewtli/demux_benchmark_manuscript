#!/bin/bash
#$ -cwd
#$ -o logs/A01d_summarize.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01d_summarize
#$ -l h_data=1G,h_rt=1:00:00
#$ -pe shared 1
#$ -t 1-36:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/demux_benchmark/adelus_2023/
cd $PROJDIR

TEMPLATE=/u/home/t/terencew/project-cluo/demux_benchmark/template_demux/
SUMMARIZE=$TEMPLATE/organize_demux.py
METHODS=$PROJDIR/txt/methods.txt

SAMPLE=20220928-IGVF-D0
LIST=$PROJDIR/ambient/ambisim/prop_doub/txt/experiments.txt

ID=${SGE_TASK_ID}
EXP=$(head -${ID} $LIST | tail -1)
echo $EXP

INDIR=$PROJDIR/ambient/ambisim/prop_doub/$EXP/regular
cd $INDIR

for METHOD in $(cat $METHODS);
do
  echo $METHOD
  time python $SUMMARIZE $INDIR $SAMPLE gex $METHOD $T
  time python $SUMMARIZE $INDIR $SAMPLE atac $METHOD $T
done

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
