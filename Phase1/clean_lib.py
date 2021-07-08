import sys

for line in sys.stdin:
    if ">" in line:
        print(line.split()[0])
    else:
        print(line[:-1])
