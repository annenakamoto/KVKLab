import sys

ALIGNMENTS = {}

curr = None
for line in sys.stdin:
    if ">" in line:
        curr = line
        if not ALIGNMENTS.get(curr):
            ALIGNMENTS[curr] = str()
    else:
        ALIGNMENTS[curr] += line

for key, value in ALIGNMENTS.items():
    print(key, value)
