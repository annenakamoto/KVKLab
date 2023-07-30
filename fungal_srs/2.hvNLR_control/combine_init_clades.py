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
        added = 0
        for k,v in MERGED.items():
            if not CLADES[clade].isdisjoint(v):
                MERGED[k] = CLADES[clade].union(v)
                added += 1
        if not added:
            MERGED[clade] = CLADES[clade]
        if added >= 2:
            print("ERROR: clade merged more than once: " + str(added) + "times")
            print(clade)
    
## print a list of genes for each clade
clade_count = 1
for k,v in MERGED.items():
    f = species + ".NLR_Clade" + str(clade_count) + ".list.txt"
    with open(f, 'w') as txt:
        for gene in v:
            txt.write(gene)
    clade_count += 1
