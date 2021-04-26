import sys

Elements = {}
for line in sys.stdin:
    words = str(line).split()
    if len(words) == 1:
        first_word = words[0]
        name = first_word.split(":")
        in_dict = Elements.get(name[0])
        if in_dict:
            Elements[name[0]] += 1
        else:
            Elements[name[0]] = 1

print(len(Elements), " unique elements.\n")

for elem, count in Elements.items():
    print(elem, "\t", count)
