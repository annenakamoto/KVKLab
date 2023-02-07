import sys

# stdin is Orthogroup line

GENES = { "guy11": 0, "US71": 0, "B71": 0, "LpKY97": 0, "MZ5-1-6": 0, "NI907": 0 }
genes_list = []

for line in sys.stdin:
    lst = line.split()
    for gene in lst[1:]:
        genome = gene.split("_")[2]
        if genome in GENES.keys():
            GENES[genome] += 1
            genes_list.append(gene)

p = True
for v in GENES.values():
    if v != 1:
        p = False

if p:
    for gene in genes_list:
        print(gene)

