import sys
import math

genome = ["guy11", "US71", "B71", "LpKY97", "MZ5-1-6"]
count = 0

for line in sys.stdin:
    lst = line.split("/")
    identity = int(lst[0])
    length = int(lst[1])
    p = (length-identity)/length
    if p < 3/4:
        jc_dist = -(3/4)*math.log(1-((4/3)*p))
        print(genome[count] + '\t' + str(jc_dist) + '\t' + line[:-1])
    else:
        print(genome[count] + '\t' + "NaN" + '\t' + line[:-1])
    count += 1

