import sys
import os
import glob

working_dir = sys.argv[1]    ## working directory (NLR_CTRL dir)
species = sys.argv[2]        ## species (Mo, Zt, Nc)

CLADES = {}     ## key=clade_name, value=set_of_genes_in_clade
## read alignment files from TREESPLIT_OUT_NACHT and TREESPLIT_OUT_NB-ARC (*.subali.afa) to get lists of genes in subclades
os.chdir(working_dir)
afa_list = glob.glob('TREESPLIT_OUT_*/*.subali.afa')
for f in afa_list:
    with open(f, 'r') as afa:
        gene_set = set()
        for line in afa:
            lst = line.split()
            if ">" in lst[0]:
                gene_set.add(lst[0][1:])
        CLADES[f] = gene_set

## merge overlapping clades
MERGED = {}
for clade in afa_list:
    if len(MERGED.keys()) == 0:
        MERGED[clade] = CLADES[clade]
    else:
        added = []
        for k,v in MERGED.items():
            if not CLADES[clade].isdisjoint(v):
                MERGED[k] = CLADES[clade].union(v)
                added.append(k)
        if not added:
            MERGED[clade] = CLADES[clade]
        if len(added) >= 2:
            print("Clade merged more than once: " + str(len(added)) + " times, merging these clades")
            print(clade)
            print(added)
            new_merged = set()
            for c in added:
                new_merged.union(MERGED[c])
                MERGED[c] = set()
            MERGED[clade] = new_merged
            print("The new merged clade has: " + str(len(new_merged)) + " genes")

    
## print a list of genes for each clade
clade_count = 1
for k,v in MERGED.items():
    if len(v) > 0:
        f = species + ".NLR_Clade" + str(clade_count) + "_" + str(len(v)) + ".list.txt"
        with open(f, 'w') as txt:
            for gene in v:
                txt.write(gene + '\n')
        clade_count += 1
