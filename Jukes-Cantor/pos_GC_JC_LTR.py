import sys

###     1: TE
###     2: RIP_analysis/name_gc_${TE}.txt
###     3: visualize_TEs/itol_JC_ds.${TE}.txt
###     4: JC_dist_indiv_TEs/itol_JC_ds_lin.${TE}.txt
###     5: LTR_divergence/itol_LTR_ds.${TE}.txt

te_name = sys.argv[1]
GC_file = sys.argv[2]
JC_one_file = sys.argv[3]
JC_lin_file = sys.argv[4]
LTR_file = sys.argv[5]

D = {}  # key=full_name, value=list (GC_content, JC_one_cons, JC_lin_cons, LTR_div)

with open(GC_file, 'r') as f1:
    for line in f1:
        if te_name in line:
            lst = line.split()
            full_name = lst[0]
            value = lst[1]
            D[full_name] = [value, "x", "x", "x"]

with open(JC_one_file, 'r') as f2:
    for line in f2:
        if te_name in line:
            lst = line.split()
            full_name = lst[0]
            value = lst[1]
            D[full_name][1] = value

with open(JC_lin_file, 'r') as f3:
    for line in f3:
        if te_name in line:
            lst = line.split()
            full_name = lst[0]
            value = lst[1]
            D[full_name][2] = value

with open(LTR_file, 'r') as f4:
    for line in f4:
        if te_name in line:
            lst = line.split()
            full_name = lst[0]
            value = lst[1]
            if D.get(full_name):
                D[full_name][3] = value

print('\t'.join(["chr", "start", "end", "TE_name", "genome", "GC_content", "JC_one_cons", "JC_lin_cons", "LTR_div"]))
### Example of ful_name: MAGGY_I#MQOP01000011.1#470091-475728{+}#guy11
for k,v in D.items():
    lst = k.split("#")
    te = lst[0]
    chrom = lst[1]
    start = lst[2][:-3].split("-")[0]
    end = lst[2][:-3].split("-")[1]
    genome = lst[3]
    print('\t'.join([chrom, start, end, te, genome] + v))
    
