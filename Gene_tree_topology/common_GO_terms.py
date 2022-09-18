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
            if not BP.get(list(goid, desc)):
                BP[list(goid, desc)] = 1
            else:
                BP[list(goid, desc)] += 1
        if ont == "MF":
            if not MF.get(list(goid, desc)):
                MF[list(goid, desc)] = 1
            else:
                MF[list(goid, desc)] += 1
        if ont == "CC":
            if not CC.get(list(goid, desc)):
                CC[list(goid, desc)] = 1
            else:
                CC[list(goid, desc)] += 1

print("*** BP ***")
for k,v in sorted(BP.items(), key=lambda kv: kv[1], reverse=True):
    print(v + "\t" + k[0] + "\t" + k[1])
print("*** MF ***")
for k,v in sorted(MF.items(), key=lambda kv: kv[1], reverse=True):
    print(v + "\t" + k[0] + "\t" + k[1])
print("*** CC ***")
for k,v in sorted(CC.items(), key=lambda kv: kv[1], reverse=True):
    print(v + "\t" + k[0] + "\t" + k[1])
