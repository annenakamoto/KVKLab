import sys

# make a dictionary of each cluster and its classification
ClustClass = {}
curClust = 0
clustSize = 0
ClustClass[curClust] = set()
for line in sys.stdin:
    if ">Cluster" in line and curClust > 0:
        if len(ClustClass[curClust]) == 0 or clustSize <= 1:
            # throw out clusters that are unclassified or that only contain one element
            ClustClass[curClust] = set(["Remove"])
        curClust += 1
        clustSize = 0
        ClustClass[curClust] = set()
    if "#" in line:
        clustSize += 1
        classification = (line.split("#")[1]).split()[0]
        if "Unknown" in classification:
            fam = line.split()[3]
            print(fam)
            if fam != "(" and fam != "[":
                ClustClass[curClust].add(fam)   # change later to add the RepeatClassifier class instead of the RepBase class, after looking at output
        else:
            ClustClass[curClust].add(classification)
    
for clust, classif in ClustClass.items():
    print(clust, "\t", ", ".join(classif))

# write new library to LIB_CLASS.fasta (adding in classifications for each cluster and with unclassified elements removed)


