import sys

group = sys.argv[1]
option = sys.argv[2]

genomes = ["MGG", "guy11", "AV1-1-1", "FJ72ZC7-77", "FJ81278", "FJ98099", "FR13", "Sar-2-20-1", "US71", "B71", "BR32", "LpKY97", "MZ5-1-6", "CD156", "NI907"]
D = {   "MGG": [],
        "AV1-1-1": [],
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
    if not line:
        if option == "names":
            ret = [group, "NONE"] + ["x"] * 15
        if option == "num":
            ret = [group, "NONE"] + ["0"] * 15
        print('\t'.join(ret))
        break
    lst = line.split()
    og = lst[0][:-1]
    for gene in lst[1:]:
        g_lst = gene.split("_")
        if len(g_lst) < 3:
            g = "MGG"
        else:
            g = g_lst[2]
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
            ret.append(str(len(D[genome])))
        print('\t'.join(ret))
    break
