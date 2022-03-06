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
    k_strand = k.split()[5]
    for e in v:
        e_strand = e.split()[5]
        if e_strand != k_strand:
            LTR[k].remove(e)
    if len(v) >= 2:
        k_left = int(k.split()[1])
        k_right = int(k.split()[2])
        left = min(v, key=lambda x:abs(int(x.split()[1])-k_left))
        right = min(v, key=lambda x:abs(int(x.split()[2])-k_right))
        if left != right:
            LTR_PAIRS[k] = [left, right]
            
### now check that each LTR is only found in the dictionary once
ltrs = []
for v in LTR_PAIRS.values():
    ltrs += v
ltrs_set = set(ltrs)
duplicates = []
print("LENGTHS: ", len(ltrs),  len(ltrs_set))
if len(ltrs) != len(ltrs_set):
    print("THERE ARE DUPLICATE LTRS")
    for ltr in ltrs_set:
        c = ltrs.count(ltr)
        if c > 1:
            print("count: ", c, ltr)
            duplicates.append(ltr)
            
### handle duplicates: only keep the best fit
for ltr in duplicates:
    print("HANDLING DUPLICATE: ", ltr)
    dup = []
    for k,v in LTR_PAIRS.items():
        if ltr in v:
            dup.append(k)
    if len(dup) < 2:
        print("couldn't find duplicate")
    elif len(dup) > 2:
        print("more than 2 duplicates found")
    else:
        print("keep one of:")
        print("0: ", dup[0])
        print("1: ", dup[1])
        ltr_rg = range(int(ltr.split()[1]), int(ltr.split()[2]))
        zero_rg = range(int(dup[0].split()[1]), int(dup[0].split()[2]))
        one_rg = range(int(dup[1].split()[1]), int(dup[1].split()[2]))
        zero_overlap = abs(max(int(dup[0].split()[1]), int(ltr.split()[1])) - min(int(dup[0].split()[2]), int(ltr.split()[2])))
        one_overlap = abs(max(int(dup[1].split()[1]), int(ltr.split()[1])) - min(int(dup[1].split()[2]), int(ltr.split()[2])))
        print("0 overlap: ", zero_overlap)
        print("1 overlap: ", one_overlap)
        if zero_overlap == one_overlap:
            print("0 and 1 dist same?? removing both")
            LTR_PAIRS.pop(dup[0])
            LTR_PAIRS.pop(dup[1])
        elif zero_overlap > one_overlap:
            print("kept 0")
            LTR_PAIRS.pop(dup[1])
        else:
            print("kept 1")
            LTR_PAIRS.pop(dup[0])
    
    

### return output 
