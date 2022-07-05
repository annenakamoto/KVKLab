import sys

# name flanking LTRs
# col 0-5 is entry 1 (LTR)
# col 6-11 is entry 2 (full TE)
# col 12 is the # bp overlap

ltr_name = (sys.argv[1]).split("_")[0]
mapping = sys.argv[2]

D = {}
# key = full element, value = list of LTR entries that overlap it
for line in sys.stdin:
    lst = line.split()
    ltr = "\t".join(lst[0:6])
    full = "\t".join(lst[6:12])
    if D.get(full):
        D[full].append(ltr)
    else:
        D[full] = [ltr]

alpha = ["a", "b", "c", "d"]
c = 1
with open(mapping, 'w') as f:
    for k,v in D.items():
        c1 = 0
        for i in v:
            e = i.split()
            n =  e[3].split("_")[0] + "_LTR_" + str(c) + "." + alpha[c1]
            e[3] = n
            print('\t'.join(e))
            f.write(str(c) + ": " + k + '\n') # keep track of what number referrs to which internal region
            c1 += 1
        c += 1
