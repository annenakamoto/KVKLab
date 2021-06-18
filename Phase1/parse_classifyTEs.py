import sys

# dictionary of RepBase (key) to RepeatClassifier (value) translations
Translate = { 
    "Academ":	    "DNA/Academ-H",
    "Copia":	    "LTR/Copia",
    "CRE":	        "LINE/CRE",
    "CryptonF":	    "DNA/Crypton-F",
    "Dada":	        "DNA/Dada",
    "DIRS":	        "LTR/DIRS",
    "DNA":	        "DNA",
    "EnSpm/CACTA":	"DNA/CMC-EnSpm",
    "Ginger2/TDD":	"DNA/Ginger-2",
    "Gypsy":	    "LTR/Gypsy",
    "Harbinger":	"DNA/PIF-Harbinger",
    "hAT":	        "DNA/hAT",
    "Helitron":	    "RC/Helitron",
    "I":	        "LINE/I",
    "IS3EU":	    "DNA/IS3EU",
    "Kolobok":	    "DNA/Kolobok-H",
    "L1":	        "LINE/L1",
    "LTR":	        "LTR",
    "Mariner/Tc1":	"DNA/TcMar-Tc1",
    "Merlin":	    "DNA/Merlin",
    "MuDR":	        "DNA/MULE-MuDR",
    "Non-LTR":	    "LINE",
    "Penelope":	    "LINE/Penelope",
    "piggyBac":	    "DNA/PiggyBac",
    "Polinton":	    "DNA/Polinton",
    "RTEX":	        "LINE/RTEX",
    "Tad1":	        "LINE/Tad1"
 }


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
        if lst[3] and Translate.get(lst[3]):
            if "Unknown" in classification:
                ClustClass[curClust].add(Translate[lst[3]])   # change later to add the RepeatClassifier class instead of the RepBase class, after looking at output
            else:
                ClustClass[curClust].add(classification)
                if Translate.get(lst[3]) != classification:   
                    print("RepeatClassifier was incorrect at: ", line)
        elif classification != "Simple_repeat" and classification != "Unknown":
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