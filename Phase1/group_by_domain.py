import sys

# Dictionary with domain (key) and list of TEs containing that domain (value)
DOMAINS = {}
# Set containing all TEs for comparison with the subsets in DOMAINS
all_elems = set()

for line in sys.stdin:
    lst = line.split()
    if len(lst) > 0:
        all_elems.add(lst[0])
        for i in range(1, len(lst)):
            dom = DOMAINS.get(lst[i].replace(",", ""))
            if dom:
                dom.add(lst[0])
            else:
                DOMAINS[lst[i].replace(",", "")] = set()
                DOMAINS[lst[i].replace(",", "")].add(lst[0])

print("There are", len(all_elems), "total elements.")

SORTED_D = sorted(DOMAINS.keys(), key=lambda x: len(DOMAINS[x]), reverse=True)

# print the domains in order from present in the most TEs to present in the least
#for dom in SORTED_D:
    #print(dom, "\t", len(DOMAINS[dom]))

pfam = ["RVT_1", "DDE_1", "rve", "Chromo", "DDE_3", "RNase_H", "RVT_2", "gag_pre-integrs", "gag-asp_proteas", "Retrotran_gag_2", "Asp_protease_2", 
            "Exo_endo_phos_2", "RVP_2", "Exo_endo_phos", "RVT_3"]
# find the set of domains s.t. every element contains at least one
uni = set()
COVER = {}
for dom in pfam:
    if not DOMAINS[dom].issubset(uni):
        tmp = uni.union(DOMAINS[dom])
        uni = tmp
        COVER[dom] = (len(uni) / len(all_elems)) * 100.00
        if uni == all_elems:
            print("Covered all elements.")
            break

#print("Intersection between RVT_1 and DDE_1:", DOMAINS["RVT_1"].intersection(DOMAINS["DDE_1"]))

#print("Set of domains s.t. every element contains at least one:")
#for dom in sorted(COVER.keys(), key=lambda x: COVER[x]):
    #print(dom, "\t", COVER[dom], "%")

#RVT_1_rve = DOMAINS["RVT_1"].intersection(DOMAINS["rve"])
#per = (len(RVT_1_rve) / len(all_elems)) * 100.00
#print("There are", len(RVT_1_rve), "elements that have both RVT_1 and rve, covering", per, "percent of the library:")
#for elem in RVT_1_rve:
    #print(elem)

for dom in pfam:
    print(dom, "\t", COVER[dom], "%")

print("\n** LIST OF TEs THAT CONATIN EACH DOMAIN **\n")
for dom in SORTED_D:
    print(">", dom, "\t", len(DOMAINS[dom]))
    n = 1
    for elem in DOMAINS[dom]:
        print(n, elem)
        n += 1
