# ambisim: single-cell multiome multiplex + ambient read simulator (https://github.com/marcalva/ambisim)
# build:  docker build -t ambisim:0.1 .
# run:    docker run --rm -v $PWD:/data -w /data ambisim:0.1 --help
FROM ubuntu:22.04 AS build

ARG AMBISIM_COMMIT=8bf86c81b83ffecc86c5b85aab27ff7692962712

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential git ca-certificates autoconf automake \
        zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev libdeflate-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# `make hts` clones and builds htslib 1.17 as a static library inside the source tree (see the ambisim Makefile)
RUN git clone https://github.com/marcalva/ambisim.git /opt/ambisim \
    && cd /opt/ambisim \
    && git checkout ${AMBISIM_COMMIT} \
    && make hts \
    && make

FROM ubuntu:22.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        zlib1g libbz2-1.0 liblzma5 libcurl4 libdeflate0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/ambisim/ambisim /usr/local/bin/ambisim

ENTRYPOINT ["ambisim"]
