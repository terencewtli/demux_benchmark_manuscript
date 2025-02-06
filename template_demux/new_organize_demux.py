#!/bin/env/py
### wrapper script to convert all demultiplexing output
### to standard dataframe output

import pandas as pd
import sys

indir = sys.argv[1]
outdir = sys.argv[2]
sample = sys.argv[3]
method = sys.argv[4]

### reformat everything so that it's in vireo style

### vireo
if method == 'vireo':
  mod = pd.read_csv(f'{indir}/{sample}/donor_ids.tsv', sep='\t', index_col=0)
  mod.to_csv(f'{outdir}/vireo.csv', sep='\t', header=True, index=True)

### vireo nogenos
if method == 'vireo_nogenos':
  mod = pd.read_csv(f'{indir}/{sample}/donor_ids.tsv', sep='\t', index_col=0)
  mod['donor_id'] = [x.replace('donor', '') for x in mod['donor_id']]
  mod.to_csv(f'{outdir}/vireo_nogenos.csv', sep='\t', header=True, index=True)

### demuxlet
if method == 'demuxlet':
  mod = pd.read_csv(f'{indir}/{sample}.best', sep='\t', index_col=1)
  d_mask = mod['DROPLET.TYPE'] == 'DBL'
  u_mask = mod['DROPLET.TYPE'] == 'AMB'
  mod.loc[d_mask,'SNG.BEST.GUESS'] = ['doublet'] * sum(d_mask)
  mod.loc[u_mask,'SNG.BEST.GUESS'] = ['unassigned'] * sum(u_mask)
  mod.rename(columns={'SNG.BEST.GUESS' : 'donor_id'}, inplace=True)
  mod.to_csv(f'{outdir}/demuxlet.csv', sep='\t', header=True, index=True)

### freemuxlet
if method == 'freemuxlet':
  mod = pd.read_csv(f'{indir}/{sample}.clust1.samples.gz',
                    sep='\t', index_col=1)

  mod['SNG.BEST.GUESS'] = [str(int(x)) for x in mod['SNG.BEST.GUESS']]

  d_mask = mod['DROPLET.TYPE'] == 'DBL'
  u_mask = mod['DROPLET.TYPE'] == 'AMB'
  mod.loc[d_mask,'SNG.BEST.GUESS'] = ['doublet'] * sum(d_mask)
  mod.loc[u_mask,'SNG.BEST.GUESS'] = ['unassigned'] * sum(u_mask)
  mod.rename(columns={'SNG.BEST.GUESS' : 'donor_id'}, inplace=True)
  mod.to_csv(f'{outdir}/freemuxlet.csv', sep='\t', header=True, index=True)

### souporcell
if method == 'souporcell':
  mod = pd.read_csv(f'{indir}/{sample}/clusters.tsv', sep='\t', index_col=0)
  d_mask = mod['status'] == 'doublet'
  u_mask = mod['status'] == 'unassigned'
  mod.loc[d_mask,'assignment'] = ['doublet'] * sum(d_mask)
  mod.loc[u_mask,'assignment'] = ['unassigned'] * sum(u_mask)
  mod.rename(columns={'assignment' : 'donor_id'}, inplace=True)
  mod.to_csv(f'{outdir}/souporcell.csv', sep='\t', header=True, index=True)

### souporcell_nogenos
if method == 'souporcell_nogenos':
  mod = pd.read_csv(f'{indir}/{sample}/clusters.tsv', sep='\t', index_col=0)
  d_mask = mod['status'] == 'doublet'
  u_mask = mod['status'] == 'unassigned'
  mod.loc[d_mask,'assignment'] = ['doublet'] * sum(d_mask)
  mod.loc[u_mask,'assignment'] = ['unassigned'] * sum(u_mask)
  mod.rename(columns={'assignment' : 'donor_id'}, inplace=True)
  mod.to_csv(f'{outdir}/souporcell_nogenos.csv', sep='\t', header=True, index=True)

### demuxalot
if method == 'demuxalot':
  mod_posts = pd.read_csv(f'{indir}/{sample}/{sample}_posteriors.csv', comment='#', sep='\t', index_col=0)
  mod_posts['assignment'] = mod_posts.idxmax(axis=1)
  mod_posts['doublet_status'] = ['+' in x for x in mod_posts['assignment']]
  mask = mod_posts['doublet_status']
  mod_posts.loc[mask,'assignment'] = 'doublet'
  mod_posts.rename(columns={'assignment' : 'donor_id'}, inplace=True)
  mod_posts.to_csv(f'{outdir}/demuxalot.csv', sep='\t', header=True, index=True)

### scsplit
if method == 'scsplit':

  barcodes = pd.read_csv(f'{indir}/{sample}/out/scSplit_P_s_c.csv', sep=',', header=0, index_col=0).index
  mod = pd.DataFrame(index = barcodes)
  mod['donor_id'] = 'unassigned'
  results = pd.read_csv(f'{indir}/{sample}/out/scSplit_result.csv', sep='\t', header=0, index_col=0)
  b_mask = mod.index.isin(results.index)
  mod.loc[b_mask,'donor_id'] = results['Cluster']

  mod['donor_id'] = [x.replace('SNG-', '') for x in mod['donor_id']]
  d_mask = ['DBL' in x for x in mod['donor_id']]
  mod.loc[d_mask,'donor_id'] = 'doublet'
  mod.to_csv(f'{outdir}/scsplit.csv', sep='\t', header=True, index=True)

### scsplit_nogenos
if method == 'scsplit_nogenos':
  ### scsplit doesn't include unassigned barcodes in
  ### final result matrix - need to merge on our own
  barcodes = pd.read_csv(f'{indir}/{sample}/out/scSplit_P_s_c.csv', sep=',', header=0, index_col=0).index
  mod = pd.DataFrame(index = barcodes)
  mod['donor_id'] = 'unassigned'
  results = pd.read_csv(f'{indir}/{sample}/out/scSplit_result.csv', sep='\t', header=0, index_col=0)
  b_mask = mod.index.isin(results.index)
  mod.loc[b_mask,'donor_id'] = results['Cluster']

  mod['donor_id'] = [x.replace('SNG-', '') for x in mod['donor_id']]
  d_mask = ['DBL' in x for x in mod['donor_id']]
  mod.loc[d_mask,'donor_id'] = 'doublet'
  mod.to_csv(f'{outdir}/scsplit_nogenos.csv', sep='\t', header=True, index=True)

### scavengers
if method == 'scavengers':
  mod = pd.read_csv(f'{indir}/{sample}/out/clusters.final.tsv', sep='\t')
  ### order is all messed up
  mod['assignment'] = mod['barcode']
  mod['barcode'] = [x[0] for x in mod.index]
  mod['status'] = [x[1] for x in mod.index]
  mod.index = mod['barcode']

  d_mask = mod['status'] == 'doublet'
  u_mask = mod['status'] == 'unassigned'
  mod.loc[d_mask,'assignment'] = ['doublet'] * sum(d_mask)
  mod.loc[u_mask,'assignment'] = ['unassigned'] * sum(u_mask)
  mod.rename(columns={'assignment' : 'donor_id'}, inplace=True)

  mod.to_csv(f'{outdir}/scavengers.csv', sep='\t', header=True, index=True)

### ambimux
if method == 'ambimux':
  mod = pd.read_csv(f'{indir}/{sample}.summary.txt',
          sep='\t', header=0, index_col=0)

  d_mask = [':' in x for x in mod['best_sample']]
  u_mask = [x == 'Empty' for x in mod['best_sample']]
  mod.loc[d_mask,'best_sample'] = ['doublet'] * sum(d_mask)
  mod.loc[u_mask,'best_sample'] = ['unassigned'] * sum(u_mask)
  mod.rename(columns={'best_sample' : 'donor_id'}, inplace=True)

  mod.to_csv(f'{outdir}/ambimux.csv', sep='\t', header=True, index=True)

### ambimux_gex
if method == 'ambimux_gex':
  mod = pd.read_csv(f'{indir}/gex/{sample}.summary.txt',
          sep='\t', header=0, index_col=0)

  d_mask = [':' in x for x in mod['best_sample']]
  u_mask = [x == 'Empty' for x in mod['best_sample']]
  mod.loc[d_mask,'best_sample'] = ['doublet'] * sum(d_mask)
  mod.loc[u_mask,'best_sample'] = ['unassigned'] * sum(u_mask)
  mod.rename(columns={'best_sample' : 'donor_id'}, inplace=True)

  mod.to_csv(f'{outdir}/ambimux_gex.csv', sep='\t', header=True, index=True)

### ambimux_atac
if method == 'ambimux_atac':
  mod = pd.read_csv(f'{indir}/atac/{sample}.summary.txt',
          sep='\t', header=0, index_col=0)

  d_mask = [':' in x for x in mod['best_sample']]
  u_mask = [x == 'Empty' for x in mod['best_sample']]
  mod.loc[d_mask,'best_sample'] = ['doublet'] * sum(d_mask)
  mod.loc[u_mask,'best_sample'] = ['unassigned'] * sum(u_mask)
  mod.rename(columns={'best_sample' : 'donor_id'}, inplace=True)

  mod.to_csv(f'{outdir}/ambimux_atac.csv', sep='\t', header=True, index=True)
