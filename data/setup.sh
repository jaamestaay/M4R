#!/bin/bash

# Command: ./setup.sh
# EXPERIMENT 1

# EXPERIMENT 2
mkdir -p experiment2
mkdir -p experiment2/logs/out
mkdir -p experiment2/logs/err
OUTDIR="experiment2"

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
        -o experiment2/logs/out \
        -e experiment2/logs/err \
        -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES,SEED=$SEED,OUTDIR=$OUTDIR \
        exp2.pbs)
      JOB_IDS+=("$JOB_ID")
    done
  done
done

# do separately for experiments
mkdir -p experiment2/postprocessing
DEPENDENCY=$(IFS=:; echo "${JOB_IDS[*]}")
qsub -W depend=afterok:$DEPENDENCY \
  -o experiment2/postprocessing \
  -e experiment2/postprocessing \
  exp2_postprocessing.pbs