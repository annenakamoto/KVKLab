import sys

group = sys.argv[1]
option = sys.argv[2]

genomes = ["70-15", "guy11", "AV1-1-1", "FJ72ZC7-77", "FJ81278", "FJ98099", "FR13", "Sar-2-20-1", "US71", "B71", "BR32", "LpKY97", "MZ5-1-6", "CD156", "NI907"]
D = {   "AV1-1-1": [],
        "B71": [],
        "BR32": [],
        "CD156": [],
        "FJ72ZC7-77": [],
        "FJ81278": [],
        "FJ98099": [],
        "FR13": [],
        "LpKY97": [],
        "MZ5-1-6": [],
        "NI907": [],
        "Sar-2-20-1": [],
        "US71": [],
        "guy11": []   }

for line in sys.stdin:
    lst = line.split()
    og = lst[0][:-1]
    for gene in lst[1:]:
        g = gene.split("_")[2]
        D[g].append(gene)
    if option == "names":
        for k in D.keys():
            if len(D[k]) == 0:
                D[k].append("x")
        ret = [group, og]
        for genome in genomes:
            ret.append(','.join(D[genome]))
        print('\t'.join(ret))
    if option == "num":
        ret = [group, og]
        for genome in genomes:
            ret.append(len(D[genome]))
        print('\t'.join(ret))
    break
