import sys

# make a dictionary of each cluster and its classification
ClustClass = {}
curClust = -1
for line in sys.stdin:
    if ">Cluster" in line:
        curClust += 1
        ClustClass[curClust] = set()
    if "#" in line:
        classification = (line.split("#")[1]).split()[0]
        if classification is "Unknown":
            fam = line.split()[3]
            if fam is not "(":
                ClustClass[curClust].add(fam)   # change later to add the RepeatClassifier class instead of the RepBase class
        else:
            ClustClass[curClust].add(classification)
        
for clust, class in ClustClass:
    print(clust, "\t", ", ".join(class))

