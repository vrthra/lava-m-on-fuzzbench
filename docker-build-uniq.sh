case $1 in
1)
docker build \
--tag gcr.io/fuzzbench/builders/benchmark/coreutils-uniq \
--build-arg BUILDKIT_INLINE_CACHE=1 \
--cache-from gcr.io/fuzzbench/builders/benchmark/coreutils-uniq \
--file benchmarks/coreutils-uniq/Dockerfile \
benchmarks/coreutils-uniq;;
2)
docker build \
--tag gcr.io/fuzzbench/builders/afl/coreutils-uniq-intermediate \
--build-arg BUILDKIT_INLINE_CACHE=1 \
--cache-from gcr.io/fuzzbench/builders/afl/coreutils-uniq-intermediate \
--build-arg parent_image=gcr.io/fuzzbench/builders/benchmark/coreutils-uniq \
--file fuzzers/afl/builder.Dockerfile \
fuzzers/afl;;
3)
docker pull ubuntu:xenial;;
4)
# Python
docker build \
--tag gcr.io/fuzzbench/base-image \
--build-arg BUILDKIT_INLINE_CACHE=1 \
--cache-from gcr.io/fuzzbench/base-image \
--file docker/base-image/Dockerfile \
.;;
5)
# Extracts LAVA
docker build \
--tag gcr.io/fuzzbench/builders/afl/coreutils-uniq \
--build-arg BUILDKIT_INLINE_CACHE=1 \
--cache-from gcr.io/fuzzbench/builders/afl/coreutils-uniq \
--build-arg benchmark=coreutils-uniq \
--build-arg fuzzer=afl \
--build-arg parent_image=gcr.io/fuzzbench/builders/afl/coreutils-uniq-intermediate \
--file docker/benchmark-builder/Dockerfile \
.;;
6)
docker build \
--tag gcr.io/fuzzbench/runners/afl/coreutils-uniq-intermediate \
--build-arg BUILDKIT_INLINE_CACHE=1 \
--cache-from gcr.io/fuzzbench/runners/afl/coreutils-uniq-intermediate \
--file fuzzers/afl/runner.Dockerfile \
fuzzers/afl;;
7)
docker build \
--tag gcr.io/fuzzbench/runners/afl/coreutils-uniq \
--build-arg BUILDKIT_INLINE_CACHE=1 \
--cache-from gcr.io/fuzzbench/runners/afl/coreutils-uniq \
--build-arg benchmark=coreutils-uniq \
--build-arg fuzzer=afl \
--file docker/benchmark-runner/Dockerfile \
.;;
8)
# runs fuzer
docker run \
--cpus=1 \
--shm-size=2g \
--cap-add SYS_NICE \
--cap-add SYS_PTRACE \
-e FUZZ_OUTSIDE_EXPERIMENT=1 \
-e FORCE_LOCAL=1 \
-e TRIAL_ID=1 \
-e FUZZER=afl \
-e BENCHMARK=coreutils-uniq \
-e FUZZ_TARGET=uniq \
-it gcr.io/fuzzbench/runners/afl/coreutils-uniq
;;
esac
