#!/usr/bin/env bash
set -e

SCRIPT=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT)
TIMEOUT=$(( 24 * 3600 ))

timestamp=$(date '+%y-%m-%d-%H-%M')
revizor_src='/home/njiang/revizor-artifact/revizor'
instructions="$revizor_src/src/x86/executor/base.json"

exp_dir="/home/njiang/revizor-artifact/results/experiment_1/$timestamp"
mkdir $exp_dir

log="$exp_dir/experiment.log"
touch $log

violations=()

for target in target1 target2 target3 target4 target5 target6 target7-8; do
    echo ""
    echo "------------------ Testing $target ---------------------------"
    echo ""
    for contract in seq bpas cond cond-bpas; do
        echo "***** Contract ct-$contract *****"
        echo ""
        name="$target-$contract"
        conf="$exp_dir/$name.yaml"

        # patch the config to set the correct contract
        cp "$SCRIPT_DIR/$target.yaml" $conf
        echo "input_gen_entropy_bits: 2
        
contract_execution_clause:" >> $conf
        if [ $contract == "seq" ]; then
            echo "- seq" >> $conf
        elif [ $contract == "cond" ]; then
            echo "- cond" >> $conf
        elif [ $contract == "bpas" ]; then
            echo "- bpas" >> $conf
        elif [ $contract == "cond-bpas" ]; then
            echo "- cond
- bpas" >> $conf
        fi

        # fuzz the target
        cd ${revizor_src}
        rvzr fuzz -s $instructions -n 100000 -i 50 --timeout $TIMEOUT -w $exp_dir -c $conf 2>&1 | tee -a $log

        # if there was a violation, save it under an understandable name
        if ls $exp_dir/violation*.asm 1> /dev/null 2>&1; then
            mv $exp_dir/violation*.asm "$exp_dir/$name-violation.asm"
            violations+=("$target violates ct-$contract")
        elif [  $contract == "seq" ] || [  $contract == "cond" ]; then
            echo ""
            echo "  No violations of CT-SEQ found, hence there is no point in testing the other contracts."
            echo "  Moving on to the next target."
            break
        fi
    done
done

echo ""
echo ""
echo "======================== Summary =============================="
echo "Detected Violations:"
for value in "${violations[@]}"; do
    echo "- $value"
done
