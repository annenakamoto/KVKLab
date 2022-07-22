import sys

JC = {}
c = 0
with open(sys.argv[1], 'r') as file:
    for line in file:
        lst = line.split()
        if len(lst) == 3:
            jc_dist = lst[1]
            JC[c] = jc_dist
            c += 1

c = 0
#print("useScore=1")
for line in sys.stdin:
    if line and ">" in line:
        # change name: : -> # and () -> {}
        name = line[1:-1]
        name1 = name.replace(":", "#")
        name2 = name1.replace("(", "{")
        name3 = name2.replace(")", "}")
        jc = str(round(float(JC[c]), 6))
        print(name3 + " " + jc)
        c += 1
