import beastform4r
import sys


prefix = sys.argv[1]
method = sys.argv[2]
n_leaves = int(sys.argv[3])
sites = int(sys.argv[4])
seed = int(sys.argv[5])
outdir = sys.argv[6]

# maybe to be redefined here?
birth_rate = 2.0
death_rate = 0.5
site_dep_prob = 0.7
site_dep_mean = 10

template = f"templates/template_{method}.xml"


tree = beastform4r.Tree(n_leaves=n_leaves,
                        birth_rate=birth_rate,
                        death_rate=death_rate,
                        method=method)

# Generate dependent data
dependent_data = tree.generate_dependent_data(
    n_indep_sites=sites,
    tiers=2,
    gain_rate=0.04,
    loss_rate=0.06,
    site_dep_prob=site_dep_prob,
    site_dep_mean=site_dep_mean,
    ascertain=True
)

n = len(dependent_data)

# Generate independent data
independent_data = []
while len(independent_data) < n:
    independent_data = tree.generate_independent_data(
        n_sites=5*n,
        gain_rate=0.04,
        loss_rate=0.06,
        ascertain=True
    )
independent_data = independent_data.sample(n=n, replace=False).copy()

print(f"Dependent sites after ascertainment: {len(dependent_data)}")
print(f"Independent sites after subsampling: {len(independent_data)}")

# Create data xml file
beastform4r.write_xml_file(
    template,
    independent_data,
    prefix,
    independent=True,
    outdir=outdir
)
beastform4r.write_xml_file(
    template,
    dependent_data,
    prefix,
    independent=False,
    outdir=outdir
)

# Creates true nexus file
beastform4r.write_nexus_tree(tree, f"{outdir}/{prefix}_true.nex")