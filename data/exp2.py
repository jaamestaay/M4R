import beastform4r
import sys
import os


prefix = sys.argv[1]
method = sys.argv[2]
n_leaves = int(sys.argv[3])
sites = int(sys.argv[4])
seed = int(sys.argv[5])
outloc = sys.argv[6]

birth_rate = float(os.environ["BIRTH_RATE"])
death_rate = float(os.environ["DEATH_RATE"])

template = f"templates/template_{method}.xml"

tree = beastform4r.Tree(n_leaves=n_leaves,
                        birth_rate=birth_rate,
                        death_rate=death_rate,
                        method=method)

# Independent Data
independent_data = []
while len(independent_data) < sites:
    independent_data = tree.generate_independent_data(
        n_sites=5*sites,
        gain_rate=0.04,
        loss_rate=0.06,
        ascertain=True
    )
independent_data = independent_data.sample(n=sites, replace=False).copy()
beastform4r.write_xml_file(
    template,
    independent_data,
    "independent",
    outdir=outloc
)

# Dependent Data
# Varying Parameters
site_dep_params_data = os.environ["SITE_DEP_PARAMS"]
site_dep_params = [
    tuple(map(float, x.split(":")))
    for x in site_dep_params_data.split()
]
tier_params = list(map(int, os.environ["TIER_PARAMS"].split()))
n, m = len(site_dep_params), len(tier_params)

for i in range(n):
    for j in range(m):
        site_dep = site_dep_params[i]
        tier = tier_params[j]
        val = i*m + j + 1
        # to ensure there is at least data generated
        shape = 0
        while not shape:
            dependent_data, tier_sizes = tree.generate_dependent_data(
                n_indep_sites=sites,
                tiers=tier,
                gain_rate=0.04,
                loss_rate=0.06,
                site_dep_prob=site_dep[0],
                site_dep_mean=site_dep[1],
                ascertain=True
            )
            shape = dependent_data.shape[0]
        # record tier sizes for later analysis
        with open(f"{outloc}/dependent_{val}_tiersizes.txt", "w") as f:
            f.write(",".join(map(str, tier_sizes)))
        beastform4r.write_xml_file(
            template,
            dependent_data,
            f"dependent_{val}",
            outdir=outloc
        )

beastform4r.write_nexus_tree(tree, f"{outloc}/true.nex")
