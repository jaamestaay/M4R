#!/bin/bash

# Command: ./submit_jobs.sh
# EXPERIMENT 1

# EXPERIMENT 2
mkdir -p experiment2
OUTDIR="experiment2"
for LEAVES in 10 #20 30 50
do
  for SEED in 1 #{1..20}
  do
    for SITES in 10 #50 100 200
    do
      PREFIX="exp2_${LEAVES}_${SEED}_${SITES}"
      METHOD="yule"
      echo "Submitting $PREFIX"
      qsub -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES,SEED=$SEED,OUTDIR=$OUTDIR exp2.pbs
    done
  done
done
# for SITES in 10 20 50 100 200
# do
#   for SEED in 1 2 3 4 5
#   do
#     PREFIX="run_sites${SITES}_seed${SEED}"
#     METHOD="yule"
#     LEAVES=30

#     echo "Submitting $PREFIX"

#     qsub -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES,SEED=$SEED run_job.pbs
#   done
# done