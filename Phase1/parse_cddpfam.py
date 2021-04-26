import sys

Elements = {}
for line in sys.stdin:
    words = str(line).split()
    if len(words) > 0 and words[0] != "" and words[1] != "unique":
        first_word = words[0]
        in_dict = Elements.get(first_word)
        if not in_dict:
            Elements[first_word] = 1

print(len(Elements), " unique elements.\n")

for elem, domains in Elements.items():
    print(elem)
