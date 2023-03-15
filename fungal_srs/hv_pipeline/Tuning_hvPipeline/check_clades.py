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

### parse mmseqs clusters
CLUSTER = {}        # key=gene, value=representative gene of cluster
count = 0
current = None
with open("Zm_panPROTEOME_clu.tsv", 'r') as f:
    for line in f:
        lst = line.split()
        rep = lst[0].upper()
        gene = lst[1].upper()           # make gene names all uppercase to match the GeneTable above
        if rep != current:              # arrived at new cluster
            count += 1
            current = rep
        CLUSTER[gene] = rep
print("Number of clusters in MMseqs2 output: " + str(count))
print()

### print dictionaries for debugging
# print("*** PRINTING CLUSTER: key=rep_gene, value=genes_in_cluster ***")
# for k,v in CLUSTER.items():
#     print(k + " : " + ",".join(v))
# print("*** PRINTING CLADE_0: key=clade_name, value=genes_in_clade ***")
# for k,v in CLADE_0.items():
#     print(k + " : " + ",".join(v))
# print("*** PRINTING CLADE_F: key=clade_name, value=genes_in_clade ***")
# for k,v in CLADE_F.items():
#     print(k + " : " + ",".join(v))
# print()

### Compare cluster sets to clade sets, report any clades that are broken
print("*** Checking for broken Clade_0 groups ***")
broken_clade_0 = []      # append to if a Clade_0 group is broken
cluster_missing_0 = []   # append to if a Clade_0 group has no corresponding cluster (this should not happen)
for clade, genes in CLADE_0.items():
    rep_genes = set([])
    for gene in genes:
        if CLUSTER.get(gene):
            rep_genes.add(CLUSTER[gene])
        else:
            print("ERROR: gene not in any cluster!")
    if len(rep_genes) > 1:          # this clade_0 has more than 1 corresponding cluster, so it was broken
        broken_clade_0.append(clade)
        print("\t" + str(len(rep_genes)) + "\t" + clade)
    elif len(rep_genes) == 0:       # this clade_0 has no corresponding cluster(s)
        cluster_missing_0.append(clade)
    else:                           # this clade_0 has 1 corresponding cluster (good), with all genes in the cluster
        pass
print("Number of broken clade_0: " + str(len(broken_clade_0)))        
print("List of broken clade_0: " + ",".join(broken_clade_0))
print("Number of clade_0 with missing cluster: " + str(len(cluster_missing_0)))        
print("List of clade_0 with missing cluster: " + ",".join(cluster_missing_0))
print()

print("*** Checking for broken Clade (final) groups ***")
broken_clade_f = []      # append to if a Clade_f group is broken
cluster_missing_f = []   # append to if a Clade_f group has no corresponding cluster (this should not happen)
for clade, genes in CLADE_F.items():
    rep_genes = set([])
    for gene in genes:
        if CLUSTER.get(gene):
            rep_genes.add(CLUSTER[gene])
        else:
            print("ERROR: gene not in any cluster!")
    if len(rep_genes) > 1:          # this clade_f has more than 1 corresponding cluster, so it was broken
        broken_clade_f.append(clade)
        print("\t" + str(len(rep_genes)) + "\t" + str(HV[clade]) + "\t" + clade)
    elif len(rep_genes) == 0:       # this clade_f has no corresponding cluster(s)
        cluster_missing_f.append(clade)
    else:                           # this clade_f has 1 corresponding cluster (good), with all genes in the cluster
        pass
print("Number of broken clade_f: " + str(len(broken_clade_f)))        
print("List of broken clade_f: " + ",".join(broken_clade_f))
print("Number of clade_f with missing cluster: " + str(len(cluster_missing_f)))        
print("List of clade_f with missing cluster: " + ",".join(cluster_missing_f))

