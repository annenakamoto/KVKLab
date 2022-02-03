import sys
import re

### Parse guy11 intersect file (argv[1]) and B71 intersect file (argv[2])
### 

guy11_intersect = sys.argv[1]
B71_intersect = sys.argv[2]

### Dictionary structure: key = <POT2 identifier>, value = <list of flanking genes>

GUY11 = {}
with open(guy11_intersect, 'r') as guy11:
    for line in guy11:
        lst = line.split()
        pot2 = '\t'.join(map(str, lst[0:4]))
        gene = '_'.join(lst[12].split("_")[:-1])
        exists = GUY11.get(pot2)
        if not exists:
            GUY11[pot2] = [gene]
        else:
            GUY11[pot2].append(gene)

B71 = {}
with open(B71_intersect, 'r') as b71:
    for line in b71:
        lst = line.split()
        pot2 = '\t'.join(map(str, lst[0:4]))
        gene = '_'.join(lst[12].split("_")[:-1])
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
            SHARED_GENES[pot2_g + " & " + pot2_b] = overlap

### print in order of most shared genes to least
SORTED_G = sorted(SHARED_GENES.keys(), key=lambda x: len(SHARED_GENES[x]), reverse=True)
for key in SORTED_G:
    g, b = re.findall('\d\.\d{6}', key)
    if abs(float(g) - float(b)) < 0.3:
        print('\t'.join([str(len(SHARED_GENES[key])), key, ';'.join(SHARED_GENES[key])]))
