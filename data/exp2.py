import beastform4r
import sys


prefix = sys.argv[1]
method = sys.argv[2]
n_leaves = int(sys.argv[3])
sites = int(sys.argv[4])
seed = int(sys.argv[5])
outdir = sys.argv[6]

birth_rate = 2.0
death_rate = 0.5

# need to vary this
site_dep_prob = 0.7
site_dep_mean = 10

template = f"templates/template_{method}.xml"
tree = beastform4r.Tree(n_leaves=n_leaves,
                        birth_rate=birth_rate,
                        death_rate=death_rate,
                        method=method)

