from pathlib import Path


def df_to_sequences(df):
    """
    Rows = cognates, columns = languages
    Output: {language: '010101...'}
    """
    sequences = {}
    for lang in df.columns:
        sequences[lang] = "".join(df[lang].astype(str).tolist())
    return sequences

# Write Nexus file for data
def write_nexus(df, outfile):
    sequences = df_to_sequences(df)

    taxa = list(sequences.keys())
    ntax = len(taxa)
    nchar = len(next(iter(sequences.values())))

    with open(outfile, "w") as f:
        f.write("#NEXUS\n\n")

        # --- TAXA block ---
        f.write("BEGIN TAXA;\n")
        f.write(f"\tDIMENSIONS NTAX={ntax};\n")
        f.write("\tTAXLABELS\n")
        for taxon in taxa:
            f.write(f"\t\t{taxon}\n")
        f.write("\t;\n")
        f.write("END;\n\n")

        # --- CHARACTERS block ---
        f.write("BEGIN CHARACTERS;\n")
        f.write(f"\tDIMENSIONS NCHAR={nchar};\n")
        f.write("\tFORMAT DATATYPE=STANDARD SYMBOLS=\"01\" STATECOUNTS=2 MISSING=? GAP=-;\n")
        f.write("\tMATRIX\n")
        for taxon in taxa:
            f.write(f"\t\t{taxon} {sequences[taxon]}\n")
        f.write("\t;\n")
        f.write("END;\n")

# Write Nexus file for true tree
def write_nexus_tree(tree, outfile):
    with open(outfile, "w") as f:
        f.write("#NEXUS\n\n")
        f.write("begin trees;\n")
        f.write(f"\tTREE true_tree = [&R] {tree.to_newick()}\n")
        f.write("END;\n")

def write_xml_file(template_filepath, df, prefix, independent=True):
    # Parse template XML and get sequences from df
    with open(template_filepath, "r") as f:
        template = f.read()
    sequences = df_to_sequences(df)
    # 1. Taxa Block
    taxa = list(sequences.keys())
    taxa_block = "\n".join(
        f'\t\t<taxon id="{taxon}"/>' for taxon in taxa
    )
    # 2. Alignment Block
    alignment_block = "\n".join(
        f"""        <sequence>
            <taxon idref="{taxon}"/>
            {sequences[taxon]}
        </sequence>"""
        for taxon in taxa
    )
    # 3. Fill Template and Write File
    if independent:
        filename = f"{prefix}_independent"
    else:
        filename = f"{prefix}_dependent"
    filled_xml = template.format(
        taxa_block=taxa_block,
        alignment_block=alignment_block,
        prefix=filename
    )
    new_dir = Path(prefix)
    new_dir.mkdir(exist_ok=True)
    new_name = f"{new_dir}/{filename}.xml"
    with open(new_name, "w") as f:
        f.write(filled_xml)