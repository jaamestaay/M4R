#!/bin/bash

# Command: ./setup_val1/setup.sh, run in data
mkdir -p validation1
mkdir -p validation1/logs/out
mkdir -p validation1/logs/err
OUTDIR="validation1"

source setup_val1/val1_config.env
read -ra LEAVES_ARR <<< "$LEAVES_LIST"
read -ra SEED_ARR <<< "$SEED_LIST"
read -ra SITES_ARR <<< "$SITES_LIST"
JOB_IDS=()
for LEAVES in "${LEAVES_ARR[@]}"
do
  for SEED in "${SEED_ARR[@]}"
  do
    for SITES in "${SITES_ARR[@]}"
    do
      PREFIX="val1_${LEAVES}_${SEED}_${SITES}"
      METHOD="yule"
      echo "Submitting $PREFIX"
      JOB_ID=$(qsub \
        -o validation1/logs/out \
        -e validation1/logs/err \
        -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES,SEED=$SEED,OUTDIR=$OUTDIR \
        setup_val1/val1.pbs)
      JOB_IDS+=("$JOB_ID")
    done
  done
done

# do separately for experiments
mkdir -p validation1/postprocessing
DEPENDENCY=$(IFS=:; echo "${JOB_IDS[*]}")
qsub -W depend=afterok:$DEPENDENCY \
  -o validation1/postprocessing \
  -e validation1/postprocessing \
  setup_val1/val1_postprocessing.pbs