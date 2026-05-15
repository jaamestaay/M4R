#!/bin/bash

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
        -o experiment2/logs/${PREFIX}_rerun.out \
        -e experiment2/logs/${PREFIX}_rerun.err \
        -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES,SEED=$SEED,OUTDIR=$OUTDIR \
        rerun_analysis.pbs)
      JOB_IDS+=("$JOB_ID")
    done
  done
done