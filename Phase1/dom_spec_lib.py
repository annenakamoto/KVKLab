import sys

domain = sys.argv[1]
WITH_DOM = {}

keep = False
lib_size = 0
with open("domain_groups_LIB.txt", 'r') as lib:
    for line in lib:
        lst = line.split()
        if len(lst) > 0 and lst[0] == ">":
            if lst[1] == domain:
                keep = True
                lib_size = int(lst[2])
            else:
                keep = False
        elif len(lst) > 0 and keep:
            WITH_DOM[lst[1]] = lst[0]

assert len(WITH_DOM) == lib_size, "error: incorrect # TEs in lib"

prt = False
for line in sys.stdin:
    lst = line.split()
    if len(lst) > 0 and lst[0] == ">":
        te = lst[1].split(":")[0]
        prt = WITH_DOM.get(te)
    if prt:
        print(line[:-1])
        
