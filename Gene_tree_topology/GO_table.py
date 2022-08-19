import sys

genome = sys.argv[1]

### construct GO term table for POT2 topo region in GENOME
###     sys.stdin is PANNZER GO output, filtered by PPV >= 0.6
###     output columns: gene_name  MF_goid BP_goid CC_goid     MF_desc BP_desc CC_desc

DATA = {}   # key=gene_name, value=[MF_goid,BP_goid,CC_goid,MF_desc,BP_desc,CC_desc]
            # if there is more than one item for any element in the list, it is added to the string separated by ;
for line in sys.stdin:
    lst = line.split('\t')
    gene_name = lst[0]
    ont = lst[1]
    goid = lst[2]
    desc = lst[3]
    if not DATA.get(gene_name):
        DATA[gene_name] = ["None"]*6
    if ont == "MF":
        if DATA[gene_name][0] != "None":
            DATA[gene_name][0] += ";" + str(goid)
            DATA[gene_name][3] += ";" + str(desc)
        else:
            DATA[gene_name][0] = str(goid)
            DATA[gene_name][3] = str(desc)
    if ont == "BP":
        if DATA[gene_name][1] != "None":
            DATA[gene_name][1] += ";" + str(goid)
            DATA[gene_name][4] += ";" + str(desc)
        else:
            DATA[gene_name][1] = str(goid)
            DATA[gene_name][4] = str(desc)
    if ont == "CC":
        if DATA[gene_name][2] != "None":
            DATA[gene_name][2] += ";" + str(goid)
            DATA[gene_name][5] += ";" + str(desc)
        else:
            DATA[gene_name][2] = str(goid)
            DATA[gene_name][5] = str(desc)

print('\t'.join(["gene_name", "MF_goid", "BP_goid", "CC_goid", "MF_desc", "BP_desc", "CC_desc"]))
for k,v in DATA.items():
    print(k + "\t" + '\t'.join(v))
