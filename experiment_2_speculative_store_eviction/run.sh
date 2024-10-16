#!/usr/bin/env bash
set -e

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
TIMEOUT=$(( 1 * 3600 ))

timestamp=$(date '+%y-%m-%d-%H-%M')
revizor_src='/home/njiang/revizor-artifact/revizor'
instructions="$revizor_src/src/x86/executor/base.json"

exp_dir="/home/njiang/revizor-artifact/results/experiment_2/$timestamp"
mkdir $exp_dir

log="$exp_dir/experiment.log"
touch $log

cd ${revizor_src}
rvzr fuzz -s $instructions -n 10000 -i 50 --timeout $TIMEOUT -w $exp_dir -c $SCRIPT_DIR/full-ct-nonspec-cond.yaml 2>&1 | tee -a $log
