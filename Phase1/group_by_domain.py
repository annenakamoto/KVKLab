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

for dom in sorted(DOMAINS.keys()):
    print(dom, len(DOMAINS[dom]))
