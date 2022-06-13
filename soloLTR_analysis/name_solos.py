import sys

ltr = (sys.argv[1]).split("_")[0]
c = 1
for line in sys.stdin:
    lst = line.split()
    lst[3] = ltr + "_LTR_" + str(c) + "solo"
    print('\t'.join(lst))
    c += 1
