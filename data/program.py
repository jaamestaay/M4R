import beastform4r

n_leaves = 30
birth_rate = 2.0
death_rate = 0.5
method = 'yule'

template = "templates/template_yule.xml"
prefix = "pytesting"

tree = beastform4r.Tree(n_leaves=n_leaves,
                        birth_rate=birth_rate,
                        method='yule')

independent_data = tree.generate_independent_data(
    n_sites=500,
    gain_rate=0.04,
    loss_rate=0.06,
    ascertain=True
)

beastform4r.write_xml_file(
    template,
    independent_data,
    prefix
)