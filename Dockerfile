FROM gcr.io/oss-fuzz-base/base-builder

RUN apt-get update && \
    apt-get upgrade -y ca-certificates && \
    apt-get install -y \
    make \
    wget \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libglib2.0-dev

COPY lava_corpus.tar.xz $SRC/lava_corpus.tar.xz
COPY lava_coreutils_patch.patch $SRC/lava_coreutils_patch.patch
COPY fuzzerentry.c $SRC/fuzzerentry.c
COPY fuzz_utils.* $SRC/

COPY build.sh $SRC/
