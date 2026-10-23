# Example: simulate a small multiplexed 10x Multiome experiment with ambisim

This example runs the simulation used in the paper on a small dataset. It takes a few minutes on one core and lets
you check that ambisim is installed and working before you simulate your own design.

## What it simulates

- **Cell-type profiles:** the 7 fibroblast cell types used in the paper (IGVF reprogramming day 0, Table SX). The
  gene and peak probabilities are restricted to chromosome 22. The last column of each probability file is the
  ambient profile, estimated from empty droplets.
- **Donors:** 4 public 1000 Genomes samples (HG00096, HG00171, HG00512, NA18486). The file contains chr22
  biallelic SNPs where at least one of the 4 donors carries the alternate allele.
- **Droplets:** 500 nuclei (10% between-donor doublets), mean ambient fraction 10% (Beta(2, 18)), 2,000 empty
  droplets, and a median of ~2,000 reads per nucleus per modality (log-normal). ATAC reads fall inside peaks with
  probability Beta(4, 6) (mean 0.4) for the nucleus and Beta(1, 9) (mean 0.1) for the ambient pool. The paper used
  the same generator with 9,000 nuclei and a median of 20,000 reads (`mk_drop_datf.R`; see "Paper settings" below).

## Requirements

- ambisim (`git clone https://github.com/marcalva/ambisim.git; cd ambisim; make hts; make`)
- samtools (to index the FASTA), wget or curl, and python3
- R (only if you regenerate the droplet table)

## Run

```bash
bash run_example.sh /path/to/ambisim/ambisim out
```

The script downloads hg38 chr22 from UCSC (`get_fasta.sh`) and runs ambisim with `--seed 1`. It then runs
`check_example.py`, which checks that every barcode in `data/drop_data.txt` received exactly the number of RNA and
ATAC reads requested, and compares the totals with `expected/read_counts.tsv`. The run ends with `PASS`.

Output (10x-style FASTQs that Cell Ranger ARC accepts):

```
out/fastq/RNA/sim_S1_L001_R{1,2}_001.fastq.gz
out/fastq/ATAC/sim_S1_L001_R{1,2,3}_001.fastq.gz
```

The true donor and cell type of each barcode are in `data/drop_data.txt` (`sam`, `ct`; doublets are
comma-separated). To demultiplex, align the FASTQs (e.g. `cellranger-arc count`) and run any method from
`scripts/` against `data/donors.chr22.vcf.gz`.

## Files

| file | description |
|---|---|
| `data/gene_probs.chr22.txt`, `data/gene_ids.chr22.txt` | per-cell-type gene probabilities (7 cell types + ambient) |
| `data/peak_probs.chr22.txt`, `data/peaks.chr22.bed` | per-cell-type peak probabilities and peak coordinates |
| `data/cell_types.txt`, `data/ct_freq.txt` | cell type IDs and frequencies |
| `data/spl_probs.txt` | probability of a spliced read (0.4 in nuclei, 0.6 ambient) |
| `data/genes.chr22.gtf.gz` | GENCODE v32 annotation (Cell Ranger ARC GRCh38-2020-A), chr22 |
| `data/donors.txt`, `data/sample_freq.txt`, `data/donors.chr22.vcf.gz` | donors, their proportions, genotypes |
| `data/drop_data.txt` | droplet table: barcodes, number of nuclei, donor(s), cell type(s), RNA reads from the nucleus and the ambient pool (`rna_nr_c`, `rna_nr_a`), ATAC reads from the nucleus and the ambient pool inside and outside peaks (`atac_nr_c_ip`, `atac_nr_a_ip`, `atac_nr_c_op`, `atac_nr_a_op`) |
| `data/wl_rna.txt`, `data/wl_atac.txt` | first 10,000 paired 10x Multiome barcodes |
| `mk_drop_datf.R` | droplet table generator (the paper's script, with the number of droplets and depth as options) |

## Your own design

Regenerate the droplet table with a different ambient level (0/10/20/30), doublet rate (%), number of nuclei,
number of empty droplets and median depth:

```bash
Rscript mk_drop_datf.R data/wl_rna.txt data/wl_atac.txt data/sample_freq.txt data/ct_freq.txt \
    1 data/drop_data.txt 20 10 500 2000 2000
```

For other donors, replace `donors.txt`, `sample_freq.txt` and the VCF. For whole-genome simulations or your own
tissue, build the profiles from a 10x Multiome run with `utils/get_top_n_bc.R` and `utils/probs_from_data.R` in the
ambisim repository, and use the full 10x barcode whitelist.

## Paper settings

The paper's simulations used 9,000 nuclei, 2–16 donors, all autosomes, and a median of 20,000 reads per nucleus per
modality (log-normal, sdlog = log 2, +200). Ambient contamination was 0/10/20/30% (Beta(2,18), (2,8), (3,7)), and the
doublet rate 0–30%. The scripts are in `scripts/ambisim/`.

The paper's droplet tables wrote the ATAC columns as nucleus total, ambient total, nucleus in-peak and ambient in-peak.
ambisim reads these four columns as nucleus in-peak, ambient in-peak, nucleus out-of-peak and ambient out-of-peak. The
simulated ATAC data therefore had ~1.35× the intended read depth, a nucleus FRiP of ~0.7 and an ambient FRiP of ~0.9, and
an ATAC ambient fraction of ~0.8× the nominal level (8%, 16% and 25% at the 10%, 20% and 30% settings). RNA was not
affected. The `mk_drop_datf.R` in this example writes the columns in the format ambisim expects.
