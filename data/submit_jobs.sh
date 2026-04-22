#!/bin/bash

for SITES in 100 200 500 1000 2000
do
  for SEED in 1 2 3 4 5
  do
    PREFIX="run_sites${SITES}_seed${SEED}"
    METHOD="yule"
    LEAVES=30

    echo "Submitting $PREFIX"

    qsub -v PREFIX=$PREFIX,METHOD=$METHOD,LEAVES=$LEAVES,SITES=$SITES run_job.pbs
  done
done