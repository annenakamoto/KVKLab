import sys
import ete2
from ete2 import Tree

OG = sys.argv[1]

Leaves = []
for line in sys.stdin:
    t = Tree(line[:-1])
    for leaf in t:
        Leaves.append(leaf.name)
    for l in Leaves:
        if l.split("_")[2] == "B71":
            b71 = t&l
            tmp1 = Leaves[:]
            tmp1.remove(l)
            b_closest = min(tmp1, key=lambda x: b71.get_distance(x))
            if b_closest.split("_")[2] == "guy11":
                guy = t&b_closest
                tmp2 = Leaves[:]
                tmp2.remove(b_closest)
                g_closest = min(tmp2, key=lambda x: guy.get_distance(x))
                if g_closest == b71.name:
                    sisters = "x"
                    for s in guy.get_sisters():
                        if s.name == b71.name:
                            sisters = "sisters"
                    print '\t'.join([OG, b71.name, guy.name, b71.get_distance(b_closest), sisters])
                    break
    print '\t'.join([OG, "x", "x", "x", "x"])
    break
