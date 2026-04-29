#!/bin/bash

for SITES in 10 20 50 100 200
do
  for SEED in 1 2 3 4 5
  do
    PREFIX="run_sites${SITES}_seed${SEED}"
    METHOD="yule"
    LEAVES=30

    echo "Submitting $PREFIX"

    qsub -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES,SEED=$SEED run_job.pbs
  done
done