import numpy as np
import pandas as pd
from scipy.io import mmread, mmwrite
import sys

from pybedtools import BedTool

cellsnp_dir = sys.argv[1]
feature = sys.argv[2]
feature_path = sys.argv[3]
outdir = sys.argv[4]

###
dp = mmread(f'{cellsnp_dir}/cellSNP.tag.DP.mtx').todense()
barcodes = pd.read_csv(f'{cellsnp_dir}/cellSNP.samples.tsv',
        sep='\t', header=None, index_col=None)[0]
vcf = pd.read_csv(f'{cellsnp_dir}/cellSNP.base.vcf.gz', sep='\t', comment='#', header=None)
feature_bed = pd.read_csv(feature_path, sep='\t', header=None, index_col=None)

###

vcf.columns = ['chrom', 'start', 'dot', 'REF', 'ALT', 'dot2', 'PASS', 'counts']
vcf['end'] = vcf['start'] + 1
vcf.index = [f'{x}_{y}' for x,y in zip(vcf['chrom'], vcf['start'])]
snps_bed = vcf[['chrom', 'start', 'end', 'REF', 'ALT', 'counts']]
tmp_dp = dp > 1

###
snps_bedtool = BedTool.from_dataframe(snps_bed)
feature_bedtool = BedTool.from_dataframe(feature_bed)

###
feature_snps = snps_bedtool.intersect(feature_bedtool).to_dataframe()
feature_snps.index = [f'{x}_{y}' for x,y in zip(feature_snps['chrom'], feature_snps['start'])]
feature_snps = feature_snps[~feature_snps.index.duplicated()]

feature_mask = vcf.index.isin(feature_snps.index)
feature_dp = dp[feature_mask,:]
tmp_feature_dp = feature_dp > 1

bc_counts = np.sum(dp, axis=0)
bc_counts_greater = np.sum(tmp_dp, axis=0)

snp_stats = pd.DataFrame(index = barcodes)
snp_stats['n_snps'] = np.sum(dp, axis=0)
snp_stats['n_snps > 1'] = np.sum(tmp_dp, axis=0)
snp_stats[f'n_snps in {feature}'] = np.sum(feature_dp, axis=0)
snp_stats[f'n_snps in {feature} > 1'] = np.sum(tmp_feature_dp, axis=0)

snp_stats.to_csv(f'{outdir}/{feature}.snp.stats.csv',
                  sep='\t', header=True, index=True)
