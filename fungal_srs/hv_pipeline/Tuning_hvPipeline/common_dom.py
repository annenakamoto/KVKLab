import sys

DOMAINS = {}    # key=domain, value=[count_arch, count_all]
for line in sys.stdin:
    lst = line.split()
    arch = lst[4].split("|")
    set_all = lst[5].split("|")
    for d in arch:
        if d != "None":
            if not DOMAINS.get(d):
                DOMAINS[d] = [1, 0]
            else:
                DOMAINS[d][0] += 1
    for d in set_all:
        if d != "None":
            n = len(d.split(",")[2]) + 1
            dom = d[:-n]
            if not DOMAINS.get(dom):
                DOMAINS[dom] = [0, 1]
            else:
                DOMAINS[dom][1] += 1

for k,v in sorted(DOMAINS.items(), key=lambda x:x[1][0], reverse=True):
    print("\t".join([k, str(v[0]), str(v[1])]))
