# Check ambisim output against the droplet table: every simulated read must carry a listed barcode, and the
# number of reads per barcode must equal the number requested. Optionally compare to the expected totals.
# Usage: python3 check_example.py drop_data.txt FASTQ_DIR [expected/read_counts.tsv]
import collections
import gzip
import sys

drop_fn, fqdir = sys.argv[1:3]
expected_fn = sys.argv[3] if len(sys.argv) > 3 else None

want_rna, want_atac = {}, {}
with open(drop_fn) as f:
    header = f.readline().rstrip('\n').split('\t')
    for line in f:
        x = dict(zip(header, line.rstrip('\n').split('\t')))
        want_rna[x['RNA_BC']] = int(x['rna_nr_c']) + int(x['rna_nr_a'])
        want_atac[x['ATAC_BC']] = sum(int(x[k]) for k in ['atac_nr_c_ip', 'atac_nr_a_ip', 'atac_nr_c_op', 'atac_nr_a_op'])


def count_barcodes(fn, bc_len):
    counts = collections.Counter()
    with gzip.open(fn, 'rt') as f:
        for i, line in enumerate(f):
            if i % 4 == 1:
                counts[line[:bc_len]] += 1
    return counts


ok = True
totals = {}
for mod, fq, want in [('RNA', 'RNA/sim_S1_L001_R1_001.fastq.gz', want_rna),
                      ('ATAC', 'ATAC/sim_S1_L001_R2_001.fastq.gz', want_atac)]:
    fn = f'{fqdir}/{fq}'
    got = count_barcodes(fn, 16)
    if set(got) - set(want):
        # the ATAC barcode read may be written as the reverse complement
        comp = str.maketrans('ACGT', 'TGCA')
        rc = collections.Counter({k.translate(comp)[::-1]: v for k, v in got.items()})
        if len(set(rc) - set(want)) < len(set(got) - set(want)):
            got = rc
    extra = set(got) - set(want)
    n_bad = sum(got[b] != n for b, n in want.items())
    totals[mod] = sum(got.values())
    print(f'{mod}: {fn}')
    print(f'  reads = {totals[mod]:,} (requested {sum(want.values()):,}); barcodes not in table = {len(extra)}; '
          f'barcodes with wrong count = {n_bad}')
    ok &= not extra and n_bad == 0

if expected_fn:
    exp = dict(line.split() for line in open(expected_fn) if not line.startswith('#'))
    for mod in totals:
        if int(exp[mod]) != totals[mod]:
            print(f'  {mod}: total differs from expected ({exp[mod]})')
            ok = False

print('PASS' if ok else 'FAIL')
sys.exit(0 if ok else 1)
