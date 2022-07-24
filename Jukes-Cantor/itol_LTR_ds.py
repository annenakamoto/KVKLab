import sys

### stdin contains: LTR(name)	pair(#)	genome	divergence
###     this will only contain entries for a particular LTR and genome
### sys.argv[1] (MAPPING/${TE}.${genome}_mapping.txt) contains: pair(#): chrom  start   end LTR(name)   score(0)    strand
###                                                 EXAMPLE:    1: MQOP01000001.1	2161562	2169220	MAGGY_I	0	+
### desired output: TE_full_name    LTR_div
###                 MAGGY_I#MQOP01000001.1#2162562-2168220{+}#guy11 0.004964

### read mapping file and make a dictionary
genome = sys.argv[2]
MAPPING = {}
with open(sys.argv[1], 'r') as m:
    for line in m:
        lst = line.split()
        pair = lst[0][:-1]
        name = lst[4] + "#" + lst[1] + "#" + lst[2] + "-" + lst[3] + "{" + lst[6] + "}#" + genome
        MAPPING[pair] = name

for line in sys.stdin:
    lst = line.split()
    pair = lst[1]
    div = lst[3]
    print(MAPPING[pair] + " " + div)
