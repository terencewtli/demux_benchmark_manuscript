#!/bin/bash
# Simulate a small multiplexed 10x Multiome experiment with ambisim (4 donors, chr22 only).
# Usage: bash run_example.sh /path/to/ambisim [OUTDIR]
# Requires: ambisim (https://github.com/marcalva/ambisim), samtools, python3 (for the check)
set -euo pipefail
AMBISIM=$1
EXDIR=$(cd "$(dirname "$0")" && pwd)
DATA=$EXDIR/data
OUT=${2:-$EXDIR/out}

if [ ! -f "$DATA/chr22.fa.fai" ]; then
    echo "$(date): downloading chr22 FASTA"
    bash "$EXDIR/get_fasta.sh" "$DATA"
fi

echo "$(date): running ambisim"
time "$AMBISIM" \
    --gtf "$DATA/genes.chr22.gtf.gz" \
    --fasta "$DATA/chr22.fa" \
    --samples "$DATA/donors.txt" \
    --cell-types "$DATA/cell_types.txt" \
    --drop-file "$DATA/drop_data.txt" \
    --expr-prob "$DATA/gene_probs.chr22.txt" \
    --gene-ids "$DATA/gene_ids.chr22.txt" \
    --mmrna-prob "$DATA/spl_probs.txt" \
    --peak-prob "$DATA/peak_probs.chr22.txt" \
    --peaks "$DATA/peaks.chr22.bed" \
    --vcf "$DATA/donors.chr22.vcf.gz" \
    --seed 1 \
    --tx-basic \
    --verbose \
    --out "$OUT/fastq"

echo "$(date): checking output"
EXPECTED=$EXDIR/expected/read_counts.tsv
[ -f "$EXPECTED" ] || EXPECTED=
python3 "$EXDIR/check_example.py" "$DATA/drop_data.txt" "$OUT/fastq" $EXPECTED
