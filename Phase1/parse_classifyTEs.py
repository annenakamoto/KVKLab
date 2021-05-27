import sys

ClassFam = {}
pound = "#"
for line in sys.stdin:
    if pound in line:
        classification = (line.split("#")[1]).split()[0]
        in_dict = ClassFam.get(classification)
        if not in_dict:
            ClassFam[classification] = 1

count = 0
for elem, count in ClassFam.items():
    print(elem)
    count += 1

print(count, " total classifications.\n")
