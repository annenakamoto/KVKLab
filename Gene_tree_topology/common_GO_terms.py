import sys

BP = {}
MF = {}
CC = {}
for line in sys.stdin:
    lst = line.split('\t')
    gene_name = lst[0]
    ont = lst[1]
    goid = lst[2]
    desc = lst[3]
    if "gene" in gene_name:
        if ont == "BP":
            if not BP.get(goid + "\t" + desc):
                BP[goid + "\t" + desc] = 1
            else:
                BP[goid + "\t" + desc] += 1
        if ont == "MF":
            if not MF.get(goid + "\t" + desc):
                MF[goid + "\t" + desc] = 1
            else:
                MF[goid + "\t" + desc] += 1
        if ont == "CC":
            if not CC.get(goid + "\t" + desc):
                CC[goid + "\t" + desc] = 1
            else:
                CC[goid + "\t" + desc] += 1

print("*** BP ***")
for k,v in sorted(BP.items(), key=lambda kv: kv[1], reverse=True):
    print(v + "\t" + k)
print("*** MF ***")
for k,v in sorted(MF.items(), key=lambda kv: kv[1], reverse=True):
    print(v + "\t" + k)
print("*** CC ***")
for k,v in sorted(CC.items(), key=lambda kv: kv[1], reverse=True):
    print(v + "\t" + k)
