import numpy as np
import pandas as pd
import sys

### handles heterozygotes
def compare_unphased_to_phased(unphased, phased):
  if unphased == '0/1' and phased == '0|1':
    return 1
  elif unphased == '0/1' and phased == '1|0':
    return 1
  else:
    return unphased.replace('/', '|') == phased

donor_path = sys.argv[1]
sample = sys.argv[2]
geno_path = sys.argv[3]
demuxlet_path = sys.argv[4]
freemux_indir = sys.argv[5]
n_clusters = int(sys.argv[6])
phased = sys.argv[7]
outdir = sys.argv[8]

donors = list(np.loadtxt(donor_path, dtype=str))

geno_columns = ['CHROM', 'POS', 'ID', 'REF',
                'ALT', 'QUAL', 'FILTER',
                'INFO', 'FORMAT'] + donors

clust_cols = [f'CLUST{x}' for x in range(n_clusters)]
freemux_columns = ['CHROM', 'POS', 'ID', 'REF',
                   'ALT', 'QUAL', 'FILTER',
                   'INFO', 'FORMAT'] + clust_cols

genotypes = pd.read_csv(geno_path, sep='\t', header=None, comment='#')
genotypes.columns = geno_columns
genotypes.index = [f'{x}_{y}' for x,y in zip(genotypes['CHROM'], genotypes['POS'])]

mask = genotypes.index.duplicated()
genotypes = genotypes[~mask]
total_snps = genotypes.shape[0]

demuxlet = pd.read_csv(demuxlet_path, sep='\t', header=0, index_col=0)
freemuxlet = pd.read_csv(f'{freemux_indir}/{sample}.clust1.samples.gz', sep='\t', header=0, index_col=0)
demuxlet.index = demuxlet['BARCODE']
freemuxlet.index = freemuxlet['BARCODE']
freemuxlet['SNG.BEST.GUESS'] = [str(int(x)) for x in freemuxlet['SNG.BEST.GUESS']]

freemuxlet_genos = pd.read_csv(f'{freemux_indir}/{sample}.clust1.vcf.gz', sep='\t', header=None, comment='#')
freemuxlet_genos.columns = freemux_columns
freemuxlet_genos.index = [f'{x}_{y}' for x,y in zip(freemuxlet_genos['CHROM'], freemuxlet_genos['POS'])]

g_mask = genotypes.index.isin(freemuxlet_genos.index)
f_mask = freemuxlet_genos.index.isin(genotypes.index)

genotypes = genotypes[g_mask]
freemuxlet_genos = freemuxlet_genos[f_mask]

for clust in clust_cols:
  freemuxlet_genos[f'{clust}_DP'] = [x.split(':')[2] for x in freemuxlet_genos[clust]]

for donor in donors:
  freemuxlet_genos[donor] = genotypes[donor]

freemuxlet['ASSIGN'] = freemuxlet['SNG.BEST.GUESS'].copy()

donor_map = {}
for i in range(n_clusters):
  barcodes = freemuxlet[freemuxlet['ASSIGN'] == f'{i}'].index
  maj_donor = demuxlet.loc[barcodes]['SNG.BEST.GUESS'].mode().values[0]
  donor_map[f'CLUST{i}'] = maj_donor
  freemuxlet['ASSIGN'].replace({f'{i}' : f'{maj_donor}'}, inplace=True)

clusts = list(donor_map.keys())
overlap_cols = ['donor', 'variant_overlap','recovered SNPs', 'total # SNPs']
vcf_overlap = pd.DataFrame(index=clusts, columns=overlap_cols, data=0)
for cluster, donor in donor_map.items():
  new_genos = pd.DataFrame(index=freemuxlet_genos.index)
  new_genos[cluster] = [x.split(':')[0] for x in freemuxlet_genos[cluster]]
  new_genos[donor] = [x.split(':')[0] for x in freemuxlet_genos[donor]]
  if phased:
    overlap = np.sum([compare_unphased_to_phased(x,y) for x,y in
                    zip(new_genos[cluster], new_genos[donor])]) / new_genos.shape[0]
  else:
      overlap = np.sum(new_genos[cluster] == new_genos[donor]) / new_genos.shape[0]
  vcf_overlap.loc[cluster] = [donor, overlap, new_genos.shape[0], total_snps]

vcf_overlap.to_csv(f'{outdir}/{sample}.overlap.csv', sep='\t', header=True, index=True)
