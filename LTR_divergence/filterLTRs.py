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
    print(">>>>>", k)
    print("\n".join(v))
    if len(v) >= 2:
        k_left = int(k.split()[1])
        k_right = int(k.split()[2])
        left = min(v, key=lambda x:abs(int(x.split()[1])-k_left))
        right = min(v, key=lambda x:abs(int(x.split()[2])-k_right))
        print("left: ", left)
        print("right: ", right)
        if left != right:
            LTR_PAIRS[k] = [left, right]
            
### now check that each LTR is only found in the dictionary once
###     if not, only keep the best fit
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
            
### handle duplicates

### return output 
