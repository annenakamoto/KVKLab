import sys

Elements = {}
for line in sys.stdin:
    words = str(line).split()
    if words[0] != "":
        first_word = words[0]
        in_dict = Elements.get(first_word)
        if in_dict:
            in_dict.append(words[1])
        else:
            Elements[first_word] = [words[1]]

print(len(Elements), " unique elements.\n")

for elem, domains in Elements.items():
    print(elem, "\t", ", ".join(domains))
