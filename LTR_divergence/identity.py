import sys

### sys.stdin: identity fraction, eg. "535/535"
### sys.argv[1]: name of LTR pair, eg. "guy11.Copia_LTR_14"

name = sys.argv[1].split(".")[1]
ltr = name.split("_")[0] + "_" + name.split("_")[1]
number = name.split("_")[2]

for line in sys.stdin:
    lst1 = line.split()
    lst2 = lst1[0].split("/")
    num = int(lst2[0])
    den = int(lst2[1])
    div = 1 - (num/den)
    result = [ltr, number, str(div)]
    print('\t'.join(result))
    break
