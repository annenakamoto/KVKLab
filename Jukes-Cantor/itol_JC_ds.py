import sys

print("DATASET_GRADIENT")
print("SEPARATOR SPACE")
print("DATASET_LABEL GC content")
print("COLOR #ff0000")
print("COLOR_MIN #ff0000")
print("COLOR_MAX #0000ff")
print("DATA")

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
        name.replace(":", "#")
        name.replace("(", "{")
        name.replace(")", "}")
        jc = str(round(float(JC[c]), 6))
        print(name + " " + jc)
        c += 1
