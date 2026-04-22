import beastform4r
import sys


prefix = sys.argv[1]
method = sys.argv[2]
n_leaves = int(sys.argv[3])
sites = int(sys.argv[4])

# maybe to be redefined here?
birth_rate = 2.0
death_rate = 0.5

template = f"templates/template_{method}.xml"


tree = beastform4r.Tree(n_leaves=n_leaves,
                        birth_rate=birth_rate,
                        death_rate=death_rate,
                        method=method)

# Generate independent data
independent_data = tree.generate_independent_data(
    n_sites=sites,
    gain_rate=0.04,
    loss_rate=0.06,
    ascertain=True
)

# Generate dependent data (TBC)

# Create data xml file
beastform4r.write_xml_file(
    template,
    independent_data,
    prefix
)

# Creates true nexus file
beastform4r.write_nexus_tree(tree, f"{prefix}/{prefix}_true.nex")