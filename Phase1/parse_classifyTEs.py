import sys

# make a dictionary of each cluster and its classification
ClustClass = {}
curClust = -1

for line in sys.stdin:
    lst = line.split()
    if lst[0] == ">Cluster":
        curClust = lst[1]
        ClustClass[lst[1]] = set()
    if "#" in line:
        classification = (line.split("#")[1]).split()[0]
        if "Unknown" in classification and lst[3]:
            if lst[3] != "(" and lst[3] != "[" and lst[3] != "...":
                ClustClass[curClust].add(lst[3])   # change later to add the RepeatClassifier class instead of the RepBase class, after looking at output
        else:
            ClustClass[curClust].add(classification)

# determine how many conflicts there are    
lib_len = 0
conflict = 0
for clust, classif in ClustClass.items():
    lib_len += 1
    if len(classif) == 0:
        classif.add("REMOVE")
    if len(classif) > 1:
        conflict += 1
print(conflict, "conflicts out of", lib_len, "elements in library")

# print the cluster number and classifications in number order
for i in range(0, len(ClustClass)):
    print(i, "\t", ", ".join(ClustClass[str(i)]))

# write new library to LIB_CLASS.fasta (adding in classifications for each cluster and with unclassified elements removed)