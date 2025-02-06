#!/bin/env/python
import pandas as pd
import sys

indir = sys.argv[1]
outdir = sys.argv[2]
sample = sys.argv[3]

autosome = [f'chr{x}' for x in range(1, 23)]
### expects Cellranger output
peaks = pd.read_csv(f'{indir}/atac_peaks.bed', header=None, index_col=0, comment='#', sep='\t')

peak_mask = peaks.index.isin(autosome)
peaks_auto = peaks[peak_mask]

peaks_auto.to_csv(f'{outdir}/{sample}.peaks.autosome.bed', header=False, index=True, sep='\t')
