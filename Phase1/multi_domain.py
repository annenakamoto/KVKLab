import sys

ALIGNMENTS = {}

curr = None
leng = 0
for line in sys.stdin:
    if ">" in line:
        curr = line
        if not ALIGNMENTS.get(curr):
            ALIGNMENTS[curr] = str()
        else:
            if leng == 0:
                leng = len(ALIGNMENTS[curr])
    else:
        ALIGNMENTS[curr] += line

for key, value in ALIGNMENTS.items():
    if len(value) > leng:
        print(key, value)
