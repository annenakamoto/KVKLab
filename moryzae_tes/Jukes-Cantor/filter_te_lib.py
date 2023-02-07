import sys

### stdin is the list of TEs of TE_NAME that we want to keep from the library at LIB_PATH

lib_path = sys.argv[1]
te_name = sys.argv[1]

TE_LIST = {}
for line in sys.stdin:
    TE_LIST[line[:-1]] = 1

with open(lib_path, 'r') as lib:
    for line in lib:
        if ">" in line:
            if line[:-1] in TE_LIST.keys():
                printing = True
                print(line[:-1])
            else:
                printing = False
        else:
            if printing == True:
                print(line[:-1])
