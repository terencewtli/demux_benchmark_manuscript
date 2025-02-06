#!/bin/env/python
import pandas as pd
import sys

indir = sys.argv[1]

barcodes = pd.read_csv(f'{indir}/scSplit_result.csv', sep='\t', header=None, comment='#').index

pd.DataFrame(index=barcodes, columns=['donor_id'])

results = pd.read_csv(f'{indir}/scSplit_result.csv', sep='\t', header=None, comment='#')

out = pd.DataFrame(vcf.index)
out.to_csv(f'{indir}/scsplit.snps.txt',sep='\t', header=None, index=False)

dp = csr_matrix(mmread(f'{indir}/cellSNP.tag.DP.mtx'))
ad = csr_matrix(mmread(f'{indir}/cellSNP.tag.AD.mtx'))

ref = dp - ad
mmwrite(f'{indir}/cellSNP.tag.REF.mtx', ref)
