# Benchmarking genotype-based demultiplexing methods in multiplexed snRNA/snATAC data

This repository contains all code relevant to the following manuscript:

Li, Terence, Marcus Alvarez, Cuining Liu, Kevin Abuhanna, Yu Sun, Jason Ernst, Kathrin Plath, Brunilda Balliu, Chongyuan Luo, and Noah Zaitlen. "The impact of ambient contamination on demultiplexing methods for single-nucleus multiome experiments." bioRxiv (2025).

Elife reviewed preprint:
[https://elifesciences.org/reviewed-preprints/106769
](https://elifesciences.org/reviewed-preprints/106769)

bioRxiv:
[https://www.biorxiv.org/content/10.1101/2025.02.06.636969v1.full.pdf
](https://www.biorxiv.org/content/10.1101/2025.02.06.636969v1.full.pdf)

## Structure of repository

| directory | contents |
|---|---|
| `docker/` | A docker recipe file and README documenting how to use ambisim with docker. |
| `example/` | An example of running ambisim on a toy example. |
| `ipynb/` | Jupyter notebooks used to process data and produce figures. |
| `scripts` | Bash scripts, primarily used for running ambisim and genotype-based demultiplexing methods. |

## Variant consistency

See [https://github.com/terencewtli/variant_consistency](https://github.com/terencewtli/variant_consistency) for details.
