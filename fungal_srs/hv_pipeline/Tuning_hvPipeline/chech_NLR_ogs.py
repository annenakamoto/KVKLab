import sys

### run in dir: /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

### parse Maize_NLRome_GeneTable clades (add each to dictionaries individually)
# key=clade, value=set of genes in clade
CLADE_0 = {}    # Clade_0 from table
CLADE_F = {}    # Clade (final clade assignment) from table
HV = {}         # key=clade_f, value=1 if hv, 0 if not
NLRs = set()    # set of all NLR genes in table
with open("Maize_NLRome_GeneTable.txt", 'r') as f:
    for line in f:
        if "Gene" not in line:
            lst = line.split()
            gene = lst[0]
            NLRs.add(gene)
            clade_0 = lst[1]
            clade_f = lst[5]
            hv = lst[9]
            HV[clade_f] = hv
            if CLADE_0.get(clade_0):            # add gene to Clade_0
                CLADE_0[clade_0].add(gene)
            else:
                CLADE_0[clade_0] = set([gene])
            if CLADE_F.get(clade_f):            # add gene to Clade_F
                CLADE_F[clade_f].add(gene)
            else:
                CLADE_F[clade_f] = set([gene])
print("Number of Clade_0: " + str(len(CLADE_0.keys())))
print()
print("Number of Clade_F: " + str(len(CLADE_F.keys())))
print()

### parse orthogroups in OrthoFinder_out/Results_Mar16/Orthogroups/Orthogroups.txt
OG = {}     # key=gene, value=orthogroup
OG_REV = {} # key=orthogroup, value=list of genes
count = 0
with open("OrthoFinder_out/Results_Mar16/Orthogroups/Orthogroups.txt", 'r') as f:
    for line in f:
        count += 1
        lst = line.split()
        og = lst[0][:-1]
        OG_REV[og] = []
        for gene in lst[1:]:
            gene_up = gene.upper()  # make gene names all uppercase to match the GeneTable above
            OG[gene_up] = og
            OG_REV[og].append(gene) 
print("Number of orthogroups: " + str(count))
print()

### print the list of OGs that contain any NLR (from Daniil's table)
NLR_OGs = set()
for clade,genes in CLADE_F.items():
    for gene in genes:
        NLR_OGs.add(OG[gene])
print("list of OGs that contain any NLR:")
print(list(NLR_OGs).join("\n"))

### print the list of OGs that contain >= 50% NLRs
for og in NLR_OGs:
    all_genes = OG_REV[og]
    num_genes = len(all_genes)
    num_nlrs = len(NLRs.intersection(set(all_genes)))
    if num_nlrs/num_genes >= 0.5:
        print(og)

### print the list of OGs that contain >= 20% NLRs
for og in NLR_OGs:
    all_genes = OG_REV[og]
    num_genes = len(all_genes)
    num_nlrs = len(NLRs.intersection(set(all_genes)))
    if num_nlrs/num_genes >= 0.2:
        print(og)
