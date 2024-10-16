#!/usr/bin/env bash
set -e

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)

timestamp=$(date '+%y-%m-%d-%H-%M')
revizor_src='/home/njiang/revizor-artifact/revizor'
instructions="$revizor_src/src/x86/executor/base.json"

exp_dir="/home/njiang/revizor-artifact/results/experiment_4/$timestamp"
mkdir $exp_dir

log="$exp_dir/experiment.log"
touch $log

# Violation of CT-SEQ
echo "------------------ Testing against CT-SEQ ---------------------------"
cd ${revizor_src}
rvzr fuzz -s $instructions -n 10000 -i 100 -w $exp_dir -c $SCRIPT_DIR/v1-ct-seq.yaml 2>&1 | tee -a $log
mv $exp_dir/violation*.asm $exp_dir/ct-seq-violation.asm

# Violation of ARCH-SEQ
echo "------------------ Testing against ARCH-SEQ ---------------------------"
cd ${revizor_src}
rvzr fuzz -s $instructions -n 10000 -i 100 -w $exp_dir -c $SCRIPT_DIR/v1-arch-seq.yaml 2>&1 | tee -a $log
mv $exp_dir/violation*.asm $exp_dir/arch-seq-violation.asm
