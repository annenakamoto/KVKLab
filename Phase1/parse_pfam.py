import sys

Elements = {}
for line in sys.stdin:
    words = str(line).split()
    first_word = words[0][:-2]
    in_dict = Elements.get(first_word)
    if in_dict:
        in_dict.append(words[6])
    else:
        Elements[first_word] = [words[6]]

print(len(Elements), " unique elements.\n")

for elem, domains in Elements.items():
    print(elem, "\t", ", ".join(domains))
