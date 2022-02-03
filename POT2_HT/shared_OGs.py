import sys

### Parse guy11 intersect file (argv[1]) and B71 intersect file (argv[2])
### 

guy11_intersect = sys.argv[1]
B71_intersect = sys.argv[2]

### Dictionary structure: key = <POT2 identifier>, value = <list of flanking genes>

GUY11 = {}
with open(guy11_intersect, 'r') as guy11:
    for line in guy11:
        lst = line.split()
        pot2 = str('\t'.join(lst[0:4]))
        gene = lst[12]
        exists = GUY11.get(pot2)
        if not exists:
            GUY11[pot2] = [gene]
        else:
            GUY11[pot2].append(gene)

B71 = {}
with open(B71_intersect, 'r') as b71:
    for line in b71:
        lst = line.split()
        pot2 = str('\t'.join(lst[0:4]))
        gene = lst[12]
        exists = B71.get(pot2)
        if not exists:
            B71[pot2] = [gene]
        else:
            B71[pot2].append(gene)

### Dictionary containing: key = <[pot2 in guy11, pot2 in b71]>, value = <list of genes in common>
SHARED_GENES = {}
for pot2_g, genes_g in GUY11.items():
    for pot2_b, genes_b in B71.items():
        overlap = list(set(genes_g) & set(genes_b))
        if overlap:
            SHARED_GENES[list(pot2_g, pot2_b)] = overlap
print(SHARED_GENES)

### print in order of most shared genes to least
SORTED_G = sorted(SHARED_GENES.keys(), key=lambda x: len(SHARED_GENES[x]), reverse=True)
for key in SORTED_G:
    print('\t'.join(str(len(SORTED_G[key])), key[0], key[1], ';'.join(SORTED_G[key])))
