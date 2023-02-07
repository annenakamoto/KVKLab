import sys

# stdin is Orthogroup line

genome_list = ["guy11", "US71", "B71", "LpKY97", "MZ5-1-6", "NI907"]

for line in sys.stdin:
    lst = line.split()
    for gene in lst[1:]:
        genome = gene.split("_")[2]
        if genome in genome_list:
            print(gene)
    break
