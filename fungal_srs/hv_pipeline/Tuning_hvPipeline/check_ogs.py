import sys

### parse Maize_NLRome_GeneTable clades (add each to dictionaries individually)
# key=clade, value=set of genes in clade
CLADE_0 = {}    # Clade_0 from table
CLADE_F = {}    # Clade (final clade assignment) from table
HV = {}         # key=clade_f, value=1 if hv, 0 if not
with open("Maize_NLRome_GeneTable.txt", 'r') as f:
    for line in f:
        if "Gene" not in line:
            lst = line.split()
            gene = lst[0]
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
count = 0
with open("OrthoFinder_out/Results_Mar16/Orthogroups/Orthogroups.txt", 'r') as f:
    for line in f:
        count += 1
        lst = line.split()
        og = lst[0][:-1]
        for gene in lst[1:]:
            gene_up = gene.upper()  # make gene names all uppercase to match the GeneTable above
            OG[gene_up] = og
print("Number of orthogroups: " + str(count))
print()


### Compare OGs to clades, report any clades that are broken
print("*** Checking for broken Clade_0 groups ***")
broken_clade_0 = []      # append to if a Clade_0 group is broken
og_missing_0 = []   # append to if a Clade_0 group has no corresponding orthogroup (this is possible)
for clade, genes in CLADE_0.items():
    orthogroups = set([])
    for gene in genes:
        if OG.get(gene):
            orthogroups.add(OG[gene])
        else:
            print("WARNING: " + gene + " not in any orthogroup")
    if len(orthogroups) > 1:          # this clade_0 has more than 1 corresponding OG, so it was broken
        broken_clade_0.append(clade)
        #print("\t" + str(len(orthogroups)) + "\t" + clade + "\t" + ",".join(orthogroups))
    elif len(orthogroups) == 0:       # this clade_0 has no corresponding OG(s)
        og_missing_0.append(clade)
    else:                           # this clade_0 has 1 corresponding OG (good), with all genes in the OG
        pass
print("Number of broken clade_0: " + str(len(broken_clade_0)))        
print("List of broken clade_0: " + ",".join(broken_clade_0))
print("Number of clade_0 with missing OG: " + str(len(og_missing_0)))        
print("List of clade_0 with missing OG: " + ",".join(og_missing_0))
print()

print("*** Checking for broken Clade (final) groups ***")
broken_clade_f = []      # append to if a Clade_f group is broken
og_missing_f = []   # append to if a Clade_f group has no corresponding OG (this is possible)
for clade, genes in CLADE_F.items():
    orthogroups = set([])
    for gene in genes:
        if OG.get(gene):
            orthogroups.add(OG[gene])
        else:
            print("WARNING: " + gene + " not in any orthogroup")
    if HV[clade] == 1:
        print("\t" + str(len(orthogroups)) + "\t" + str(HV[clade]) + "\t" + clade + "\t" + ",".join(orthogroups))
    if len(orthogroups) > 1:          # this clade_f has more than 1 corresponding OG, so it was broken
        broken_clade_f.append(clade)
    elif len(orthogroups) == 0:       # this clade_f has no corresponding OG(s)
        og_missing_f.append(clade)
    else:                           # this clade_f has 1 corresponding OG (good), with all genes in the OG
        pass
print("Number of broken clade_f: " + str(len(broken_clade_f)))        
print("List of broken clade_f: " + ",".join(broken_clade_f))
print("Number of clade_f with missing OG: " + str(len(og_missing_f)))        
print("List of clade_f with missing OG: " + ",".join(og_missing_f))

