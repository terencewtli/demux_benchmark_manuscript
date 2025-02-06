import pandas as pd
from scipy.io import mmread, mmwrite
import sys
import os

indir = sys.argv[1]
outdir = sys.argv[2]
bc_list = sys.argv[3]

ad = mmread(f'{indir}/cellSNP.tag.AD.mtx').tocsr()
dp = mmread(f'{indir}/cellSNP.tag.DP.mtx').tocsr()
oth = mmread(f'{indir}/cellSNP.tag.OTH.mtx').tocsr()

barcodes = pd.read_csv(f'{indir}/cellSNP.samples.tsv', index_col=0, header=None)

subset_bcs = pd.read_csv(bc_list, index_col=0, header=None)

mask = subset_bcs.index.isin(barcodes.index)
ad = ad[:,mask]
dp = dp[:,mask]
oth = oth[:,mask]

os.mkdir(outdir)
subset_bcs.to_csv(f'{outdir}/cellSNP.samples.tsv',sep='\t', header=0, index=True)

mmwrite(f'{outdir}/cellSNP.tag.AD.mtx', ad)
mmwrite(f'{outdir}/cellSNP.tag.DP.mtx', dp)
mmwrite(f'{outdir}/cellSNP.tag.OTH.mtx', oth)

os.system(f'cp {indir}/cellSNP.base.vcf.gz* -t {outdir}')
