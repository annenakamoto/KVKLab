import sys

### INPUT: a fasta header (name) of a TE
### OUTPUT: a bedfile entry line for the TE
###     example: >MAGGY_I:UCNY03000025.1:94032-98838(+):US71
###              UCNY03000025.1  94032   98838   MAGGY_I   0   +

HEADERS = {}
for header in sys.stdin:
    if not HEADERS.get(header, False):
        HEADERS[header] = True
        lst = header.split(":")
        tmp = lst[2].split("(")
        coords = tmp[0].split("-")
        start = coords[0]
        end = coords[1]
        strand = tmp[1][0]
        print(lst[1] + "\t" + start + "\t" + end + "\t" + lst[0][1:] + "\t" + "0" + "\t" + strand)
