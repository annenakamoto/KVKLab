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

for line in sys.stdin:
    t = Tree(line)
    t.prune(genomes)    # only keep leaves with the rep genome names
    s = str(t.write())  # write the tree as a string
    # replace the genome names with shortened 3-letter versions
    for k, v in REPLACE.items():
        s = s.replace(k, v)
    print s
    break
