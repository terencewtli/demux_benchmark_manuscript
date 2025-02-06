#!/bin/env/python
import pandas as pd
from scipy.io import mmread, mmwrite
from scipy.sparse import csr_matrix
import sys

indir = sys.argv[1]

vcf = pd.read_csv(f'{indir}/cellSNP.base.vcf.gz', sep='\t', header=None, comment='#')
vcf.index = [f'{x}:{y}' for x,y in zip(vcf[0], vcf[1])]

out = pd.DataFrame(vcf.index)
out.to_csv(f'{indir}/scsplit.snps.txt',sep='\t', header=None, index=False)

dp = csr_matrix(mmread(f'{indir}/cellSNP.tag.DP.mtx'))
ad = csr_matrix(mmread(f'{indir}/cellSNP.tag.AD.mtx'))

ref = dp - ad
mmwrite(f'{indir}/cellSNP.tag.REF.mtx', ref)
