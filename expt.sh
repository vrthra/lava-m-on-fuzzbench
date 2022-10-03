echo "To run an experiment:"
echo "cd fuzzbench; PYTHONPATH=. python3 experiment/run_experiment.py --experiment-config ~/local.yaml --benchmarks coreutils-uniq  --experiment-name a0 --fuzzers  aflplusplus_um_prioritize  aflplusplus"
echo
echo "To check a specific benchmark"
echo export FUZZER_NAME=afl
echo export BENCHMARK_NAME=coreutils-uniq

export FUZZER_NAME=afl
export BENCHMARK_NAME=coreutils-uniq

echo "cd fuzzbench; make build-$FUZZER_NAME-$BENCHMARK_NAME"

echo "cd fuzzbench; make run-$FUZZER_NAME-$BENCHMARK_NAME"
#fi
