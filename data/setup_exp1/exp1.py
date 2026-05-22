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
probs_data = os.environ["PROBS"]
probs_data = list(map(float, probs_data.split(" ")))
tier_params = list(map(int, os.environ["TIER_PARAMS"].split()))
n, m = len(probs_data), len(tier_params)

for i in range(n):
    for j in range(m):
        prob_indep = probs_data[i]
        tier = tier_params[j]
        val = i*m + j + 1
        dependent_data = tree.generate_dependent_data_fixed(
            n_sites=sites,
            tiers=tier,
            gain_rate=0.04,
            loss_rate=0.06,
            prob_indep=prob_indep,
            ascertain=True
        )
        beastform4r.write_xml_file(
            template,
            dependent_data,
            f"dependent_{val}",
            outdir=outloc
        )

beastform4r.write_nexus_tree(tree, f"{outloc}/true.nex")
