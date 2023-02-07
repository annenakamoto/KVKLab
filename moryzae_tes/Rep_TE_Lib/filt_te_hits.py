import sys

### filters the library in stdin to only keep those with domains
### argv[1] is the file containing the list of the TEs to keep

te_list_name = sys.argv[1]

TE_LIST = {}
with open(te_list_name, 'r') as list:
    for line in list:
        TE_LIST[line[:-1]] = 1

printing = False
for line in sys.stdin:
    if ">" in line:
        if line[1:-1] in TE_LIST.keys():
            printing = True
            print(line[:-1])
        else:
            printing = False
    else:
        if printing == True:
            print(line[:-1])
