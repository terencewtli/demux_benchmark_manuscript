# ambisim container

Container recipes for [ambisim](https://github.com/marcalva/ambisim), the multiplexed snRNA/snATAC simulator with
ambient contamination used in this study. Both recipes build the same ambisim version used for the manuscript
(commit `8bf86c8`) with htslib 1.17, on Ubuntu 22.04.

| file | for |
|---|---|
| `Dockerfile` | Docker (laptops, cloud) |
| `ambisim.def` | Apptainer / Singularity (HPC clusters) |

## Build

Docker:
```bash
docker build -t ambisim:0.1 .
```

Apptainer (no root needed):
```bash
apptainer build --fakeroot ambisim.sif ambisim.def
```

On some clusters the apptainer module sets `APPTAINER_BIND` to paths that do not exist inside the image, and the
build fails with `destination ... doesn't exist in container`. Build with the variable unset:
```bash
env -u APPTAINER_BIND apptainer build --fakeroot ambisim.sif ambisim.def
```

## Run

The container's entry point is `ambisim`, so arguments are passed straight through:
```bash
docker run --rm ambisim:0.1 --help
apptainer run ambisim.sif --help
```

To simulate, mount the directory holding the inputs and the output folder. The input files (droplet table, GTF,
FASTA, VCF, cell types, gene/peak/splice probabilities, peaks BED) are described in the
[ambisim README](https://github.com/marcalva/ambisim#input-files). This is the call used for the simulations in the
manuscript:

```bash
# Docker: everything under $PWD is visible as /data
docker run --rm -v "$PWD":/data -w /data ambisim:0.1 \
    --gtf genes_autosome.gtf \
    --fasta genome_autosomal.fa \
    --vcf donors.vcf.gz \
    --samples donors.txt \
    --cell-types cell_types.txt \
    --drop-file drop_data.txt \
    --expr-prob gene_probs.txt \
    --gene-ids gene_ids.txt \
    --mmrna-prob spl_probs.txt \
    --peak-prob peak_probs.txt \
    --peaks peaks.bed \
    --seed 1 --tx-basic --verbose \
    --out sim_out

# Apptainer: the current directory is mounted by default; add --bind for inputs elsewhere
apptainer run --bind /path/to/inputs ambisim.sif \
    --gtf /path/to/inputs/genes_autosome.gtf \
    ...same arguments as above... \
    --out sim_out
```

The output folder gets `RNA/` and `ATAC/` subdirectories of FASTQ files, which can be aligned with Cell Ranger ARC as
for a real multiome run.

Notes:
- With Docker, files written to the mounted directory are owned by root unless you add `--user $(id -u):$(id -g)`.
- `--vcf` must be indexed (`.tbi` or `.csi` next to the VCF), and the FASTA must have a `.fai` index.
- Chromosome names must match between the FASTA, GTF, VCF and peaks BED.

## Verification

We ran the ambisim command used for the manuscript simulations (2-donor pool, `--seed 1`, 30 droplets, GRCh38
autosomes) once with the natively compiled binary used in the paper and once in the Apptainer image built from
`ambisim.def`. All five output FASTQ files (RNA R1/R2, ATAC R1/R2/R3) were byte-identical. The Docker image uses the
same base image and build steps but was not itself built for this test.
