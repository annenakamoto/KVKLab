import sys

DOM_ARCH = {}   # key=domain_architecture, value=count
for line in sys.stdin:
    lst = line.split()
    og = lst[0]
    arch = lst[4]
    if DOM_ARCH.get(arch):
        DOM_ARCH[arch].append(og)
    else:
        DOM_ARCH[arch] = [og]

for k,v in sorted(DOM_ARCH.items(), key=lambda x:len(x[1]), reverse=True):
    print(k + "\t" + str(len(v)) + "\t" + ",".join(v))
