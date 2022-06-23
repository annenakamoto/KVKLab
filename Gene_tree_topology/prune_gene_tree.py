import sys
from ete2 import Tree

### must activate conda env treeKO for ete2 and python2.7

genomes = sys.argv[1].split()

REPLACE = { "guy11": "GUY",
            "US71": "US7",
            "B71": "B71",
            "LpKY97": "LPK", 
            "MZ5-1-6": "MZ5",
            "NI907": "NI9" }

KEEP = {}
for line in sys.stdin:
    for k in genomes:
        temp = line.split(k)
        for i in temp:
            if i[0] == "_" and i[-1] == "_":
                 # create a mapping of the current name (key) to the new name to replace it with (value)
                 # current format: NI907_gene_544_NI907
                 # want: NI9_544
                KEEP[k + i + k] = REPLACE[k] + "_" + i.split("_")[2]
    t = Tree(line)
    t.prune(KEEP.keys())
    s = t.write()
    for k,v in KEEP.items():
        s = s.replace(k, v) # replace the original name (k) with the reformatted name (v)
    print s
    break
