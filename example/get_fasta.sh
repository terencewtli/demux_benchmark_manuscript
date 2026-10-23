#!/bin/bash
# Download hg38 chr22 from UCSC, uppercase it (the paper used an unmasked FASTA) and index it.
# Usage: bash get_fasta.sh OUTDIR
# Requires: wget or curl, samtools
set -euo pipefail
OUTDIR=$1
URL=https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr22.fa.gz
mkdir -p "$OUTDIR"
if command -v wget > /dev/null; then
    wget -q -O "$OUTDIR/chr22.fa.gz" "$URL"
else
    curl -sSL -o "$OUTDIR/chr22.fa.gz" "$URL"
fi
gzip -dc "$OUTDIR/chr22.fa.gz" | awk '/^>/ {print; next} {print toupper($0)}' > "$OUTDIR/chr22.fa"
rm "$OUTDIR/chr22.fa.gz"
samtools faidx "$OUTDIR/chr22.fa"
echo "wrote $OUTDIR/chr22.fa"
