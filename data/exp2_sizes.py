import pandas as pd
import sys
import os


prefix = sys.argv[1]
method = sys.argv[2]
n_leaves = int(sys.argv[3])
sites = int(sys.argv[4])
seed = int(sys.argv[5])
outloc = sys.argv[6]

# find files and analyse them
site_dep_params_data = os.environ["SITE_DEP_PARAMS"]
site_dep_params = [
    tuple(map(float, x.split(":")))
    for x in site_dep_params_data.split()
]
tier_params = list(map(int, os.environ["TIER_PARAMS"].split()))
n, m = len(site_dep_params), len(tier_params)

# store tier sizes as a dataframe for analysis
tier_sizes_df = pd.DataFrame(columns=["site_dep_param", "tier", "size"])

for i in range(n):
    for j in range(m):
        val = i*m + j + 1
        with open(f"{outloc}/dependent_{val}_tiersizes.txt", "r") as f:
            tier_sizes = [int(x) for x in f.read().strip().split(",")]
            for k, size in enumerate(tier_sizes):
                tier_sizes_df = tier_sizes_df.append({
                    "site_dep_param": site_dep_params[i],
                    "tier": tier_params[j],
                    "size": size
                }, ignore_index=True)

tier_sizes_df.to_csv(f"{outloc}/tier_sizes.csv", index=False)
