#!/bin/bash
#$ -cwd
#$ -o logs/A01a_setup_dirs.$JOB_ID.$TASK_ID
#$ -j y
#$ -N A01a_setup_dirs
#$ -l h_data=2G,h_rt=15:00:00
#$ -pe shared 8
#$ -t 1-7:1

echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID started on:   " `date `
echo " "

source ~/.bashrc

conda activate allcools

PROJDIR=/u/home/t/terencew/project-cluo/demux_benchmark/adelus_2023/
cd $PROJDIR

SAMPLES=$PROJDIR/txt/samples.txt
DEMUX=$PROJDIR/txt/demux_dirs.txt

### the type of demultiplexing experiment that I'm doign
TEST=regular
cd $PROJDIR/demux/$TEST

for f in $(cat $DEMUX);
do
  mkdir -p $f
  mkdir -p $f/atac $f/gex
  for g in $(cat $SAMPLES);
  do
    mkdir -p $f/atac/$g $f/gex/$g
  done
done

echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `hostname -s`
echo "Job $JOB_ID.$SGE_TASK_ID ended on:   " `date `
echo " "
