import sys

leng = 0
curr = None
for line in sys.stdin:
    if ">" in line:
        if curr:
            print(curr, "\t", leng)
        leng = 0
        curr = line.split()[0]
    else:
        leng += len(line[:-1])
    
print(leng)
