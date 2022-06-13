import sys

### key = internal, value = list of LTRs
LTR = {}
for line in sys.stdin:
    lst = line.split()
    k = "\t".join(lst[0:6])
    v = "\t".join(lst[6:12])
    if LTR.get(k):
        LTR[k].append(v)
    else:
        LTR[k] = [v]

### keep entries from LTR that have a pair of appropriate flanking LTRs
###     don't include if only one element in list
###     if >=2 in list, assign two of them to "LEFT" and "RIGHT" LTRs
###         if this can't be done, then don't include
### key = internal, value = list of 2 flanking LTRs
LTR_PAIRS = {}
for k,v in LTR.items():
    ### remove entries in v that don't have the same strand (+/-)
    # k_strand = k.split()[5]
    # for e in v:
    #     e_strand = e.split()[5]
    #     if e_strand != k_strand:
    #         LTR[k].remove(e)
    if len(v) >= 1:
        k_left = int(k.split()[1])+1000     # correct for the 1000 bp added to each side using slop
        k_right = int(k.split()[2])-1000
        left = min(v, key=lambda x:abs(int(x.split()[1])-k_left))
        right = min(v, key=lambda x:abs(int(x.split()[2])-k_right))
        if left != right and left.split()[5] == right.split()[5]: ### check that the left and right aren't the same and that they have the same strand (can be different from the internal region)
            LTR_PAIRS[k] = [left, right]
        if left == right:
            if abs(int(left.split()[1])-k_left) < abs(int(right.split()[2])-k_right):
                LTR_PAIRS[k] = [left, "NULL"]
            else:
                LTR_PAIRS[k] = ["NULL", right]
            
### now check that each LTR is only found in the dictionary once
ltrs = []
for v in LTR_PAIRS.values():
    ltrs += v
ltrs.remove("NULL")
ltrs_set = set(ltrs)
duplicates = []
# print("LENGTHS: ", len(ltrs),  len(ltrs_set))
if len(ltrs) != len(ltrs_set):
    # print("THERE ARE DUPLICATE LTRS")
    for ltr in ltrs_set:
        c = ltrs.count(ltr)
        if c > 1:
            # print("count: ", c, ltr)
            duplicates.append(ltr)
            
### handle duplicates: only keep the best fit
for ltr in duplicates:
    # print("HANDLING DUPLICATE: ", ltr)
    dup = []
    for k,v in LTR_PAIRS.items():
        if ltr in v:
            dup.append(k)
    if len(dup) == 2:
        # print("keep one of:")
        # print("0: ", dup[0])
        # print("1: ", dup[1])
        zero_overlap = abs(max(int(dup[0].split()[1])+1000, int(ltr.split()[1])) - min(int(dup[0].split()[2])-1000, int(ltr.split()[2])))
        one_overlap = abs(max(int(dup[1].split()[1])+1000, int(ltr.split()[1])) - min(int(dup[1].split()[2])-1000, int(ltr.split()[2])))
        # print("0 overlap: ", zero_overlap)
        # print("1 overlap: ", one_overlap)
        if zero_overlap == one_overlap:
            # print("0 and 1 dist same?? removing both")
            LTR_PAIRS.pop(dup[0])
            LTR_PAIRS.pop(dup[1])
        elif zero_overlap > one_overlap:
            # print("kept 0")
            LTR_PAIRS.pop(dup[1])
        else:
            # print("kept 1")
            LTR_PAIRS.pop(dup[0])

### return output 
### rename the LTRs
c = 1
with open(sys.argv[1], 'w') as f:
    for k,v in LTR_PAIRS.items():
        if v[0] != "NULL":
            v0 = v[0].split()
            n0 = v0[3].split("_")[0] + "_LTR_" + str(c) + "a"
            v0[3] = n0
            print('\t'.join(v0))
        if v[1] != "NULL":
            v1 = v[1].split()
            n1 = v1[3].split("_")[0] + "_LTR_" + str(c) + "b"
            v1[3] = n1
            print('\t'.join(v1))
        f.write(str(c) + ": " + k + '\n') # keep track of what number referrs to which internal region
        c += 1



