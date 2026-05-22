import sys
import pandas as pd


leaves_list = sys.argv[1].split(" ")
seed_list = sys.argv[2].split(" ")
sites_list = sys.argv[3].split(" ")

def file_name_trees(leaves, seed, sites):
    return f"experiment2/exp2_{leaves}_{seed}_{sites}/tree_comparison_results.csv"

def process_data_trees(leaves, seed, sites, flag):
    data = pd.read_csv(file_name_trees(leaves, seed, sites))
    data['ZIP'] = list(zip(data["prob"], data["mean"]))
    data['ZIP'] = 'ZIP' + data['ZIP'].astype(str)
    data.loc[data["ZIP"] == "ZIP(0.0, 0.0)", "ZIP"] = "independent"
    data = data.drop(columns=["dataset", "id", "prob", "mean"])
    data['leaves'] = leaves
    data['independent_sites'] = sites
    data.to_csv(
        "experiment2/postprocessing/exp2_combined_data.csv",
        mode="w" if flag else "a",
        header=flag,
        index=False
    )
    # if data.shape[0] - 13:
    #     print(file_name(leaves, seed, sites), data.shape[0])


# Combine all data into one file
flag = True
for leaves in leaves_list:
    for seed in seed_list:
        for sites in sites_list:
            process_data_trees(leaves, seed, sites, flag)
            flag = False

