#!/bin/bash

# experiment 2 extension setup - deleted parents
mkdir -p experiment2e
mkdir -p experiment2e/logs/out
mkdir -p experiment2e/logs/err
OUTDIR="experiment2e"

source exp2_config.env
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
      PREFIX="exp2_${LEAVES}_${SEED}_${SITES}"
      METHOD="yule"
      echo "Submitting $PREFIX"
      JOB_ID=$(qsub \
        -o experiment2e/logs/out \
        -e experiment2e/logs/err \
        -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES,SEED=$SEED,OUTDIR=$OUTDIR \
        exp2_e.pbs)
      JOB_IDS+=("$JOB_ID")
    done
  done
done

# do separately for experiments
mkdir -p experiment2e/postprocessing
DEPENDENCY=$(IFS=:; echo "${JOB_IDS[*]}")
qsub -W depend=afterok:$DEPENDENCY \
  -o experiment2e/postprocessing \
  -e experiment2e/postprocessing \
  exp2_postprocessing.pbs