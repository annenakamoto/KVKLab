import sys
import math

te = sys.argv[1]

for line in sys.stdin:
    lst = line.split("/")
    identity = int(lst[0])
    length = int(lst[1])
    p = (length-identity)/length
    if p < 3/4:
        jc_dist = -(3/4)*math.log(1-((4/3)*p))
        if jc_dist < 1:
            print(te + '\t' + str(jc_dist) + '\t' + line)
