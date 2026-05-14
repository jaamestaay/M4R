#!/bin/bash

# Command: ./setup.sh
# EXPERIMENT 1

# EXPERIMENT 2
mkdir -p experiment2
mkdir -p experiment2/logs/out
mkdir -p experiment2/logs/err
OUTDIR="experiment2"

LEAVES_LIST=(10 20 30 50)
SEED_LIST=({1..20})
SITES_LIST=(10 50 100 200)
JOB_IDS=()
for LEAVES in "${LEAVES_LIST[@]}"
do
  for SEED in "${SEED_LIST[@]}"
  do
    for SITES in "${SITES_LIST[@]}"
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
LEAVES_STR=$(IFS=,; echo "${LEAVES_LIST[*]}")
SEED_STR=$(IFS=,; echo "${SEED_LIST[*]}")
SITES_STR=$(IFS=,; echo "${SITES_LIST[*]}")
DEPENDENCY=$(IFS=:; echo "${JOB_IDS[*]}")
qsub -W depend=afterok:$DEPENDENCY \
  -o experiment2/postprocessing \
  -e experiment2/postprocessing \
  -v LEAVES_LIST="$LEAVES_STR",SEED_LIST="$SEED_STR",SITES_LIST="$SITES_STR" \
  exp2_postprocessing.pbs