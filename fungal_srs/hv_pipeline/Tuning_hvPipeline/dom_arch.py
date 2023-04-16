import sys

orthogroup = sys.argv[1]    # the OG is passed as an argument
num_genes = sys.argv[2]     # the total number of genes in the OG is passed as an argument

DOMAINS = {}    # key=domain "name,id", value=count
ARCHS = {}      # key=gene, value=ordered list of domains "name,id"
num_hits = 0
for line in sys.stdin:
    lst = line.split()
    if len(lst) > 0 and "Mo" in lst[0]:
        num_hits += 1
        gene = lst[0]
        pfid = lst[5]
        pfname = lst[6]
        dom = pfname + "," + pfid
        if DOMAINS.get(dom):
            DOMAINS[dom] += 1
        else:
            DOMAINS[dom] = 1
        if ARCHS.get(gene):
            ARCHS[gene].append(dom)
        else:
            ARCHS[gene] = [dom]

### make the set of all domains in the OG and their counts into one line: (name,id):1;
if num_hits > 0:
    dom_counts = ""
    for k,v in DOMAINS.items():
        dom_counts += k + "," + str(v) + "|"
    dom_counts = dom_counts[:-1]
else:
    dom_counts = "None"

COMMON_ARCH = {}    # key=arch, value=count
common_domarch = "None"
### find the most common domain architecture in the OG
for arc in ARCHS.values():
    arc_str = "|".join(arc)
    if COMMON_ARCH.get(arc_str):
        COMMON_ARCH[arc_str] += 1
    else:
        COMMON_ARCH[arc_str] = 1
high_count = 0
for k,v in COMMON_ARCH.items():
    if v > high_count:
        common_domarch = k
        high_count = v
perc_common = round(high_count / int(num_genes), 2)

### Output line: OG, num_genes_in_OG, num_total_pfamscan_hits, percent_genes_with_common_arch, most_common_domarch, set_of_all_domains_in_OG_and_counts
out = [orthogroup, str(num_genes), str(num_hits), str(perc_common), common_domarch, dom_counts]
print("\t".join(out))
