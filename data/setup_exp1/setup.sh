#!/bin/bash

# Command: ./setup_exp1/setup.sh, run in data
# EXPERIMENT 1
mkdir -p experiment1
mkdir -p experiment1/logs/out
mkdir -p experiment1/logs/err
OUTDIR="experiment1"

source setup_exp1/exp1_config.env
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
      PREFIX="exp1_${LEAVES}_${SEED}_${SITES}"
      METHOD="yule"
      echo "Submitting $PREFIX"
      JOB_ID=$(qsub \
        -o experiment1/logs/out \
        -e experiment1/logs/err \
        -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES,SEED=$SEED,OUTDIR=$OUTDIR \
        setup_exp1/exp1.pbs)
      JOB_IDS+=("$JOB_ID")
    done
  done
done

# do separately for experiments
mkdir -p experiment1/postprocessing
DEPENDENCY=$(IFS=:; echo "${JOB_IDS[*]}")
qsub -W depend=afterok:$DEPENDENCY \
  -o experiment1/postprocessing \
  -e experiment1/postprocessing \
  setup_exp1/exp1_postprocessing.pbs