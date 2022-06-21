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
    ltr = lst[0:5]
    full = lst[6:11]
    overlap = int(lst[12])




c = 1
with open(mapping, 'w') as f:
    
    f.write(str(c) + ": " + k + '\n') # keep track of what number referrs to which full element
    c += 1