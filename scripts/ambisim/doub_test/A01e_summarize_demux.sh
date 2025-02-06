#!/bin/bash
#$ -cwd
#$ -o logs/A01e_summarize.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01e_summarize
#$ -l h_data=1G,h_rt=1:00:00
#$ -pe shared 1
#$ -t 1-16:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/igvf/pilot/multiome
cd $PROJDIR

TEMPLATE=/u/project/cluo/terencew/demux_benchmark/template_demux

SAMPLE=20220928-IGVF-D0

LIST=$PROJDIR/ambient/ambisim/prop_doub/txt/experiments.txt

# ID=1
ID=${SGE_TASK_ID}
CONFIG=$(head -${ID} $LIST | tail -1)

INDIR=$PROJDIR/ambient/ambisim/prop_doub/$CONFIG
cd $INDIR

DEMUX_DIR=$INDIR/demux/

SUMMARIZE=$TEMPLATE/new_organize_demux.py
METHODS=$PROJDIR/ambient/ambisim/prop_doub/txt/methods.txt

MODS=(atac gex)

for METHOD in $(cat $METHODS);
do
  echo $METHOD
  for MOD in ${MODS[@]};
  do
      INDIR=$DEMUX_DIR/$METHOD/${MOD}/
      OUTDIR=$DEMUX_DIR/merged/${MOD}/$SAMPLE/
      time python $SUMMARIZE $INDIR $OUTDIR $SAMPLE $METHOD
  done
done

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "
