import re
import sys

### Processes Pierre gff3 so gene names match faa
### original gff is in sys.stdin

genome = sys.argv[1]    ### new name of genome
print(genome)
new_gff = sys.argv[2]   ### path to save new processed gff at

with open(new_gff, 'w') as corrected:
    for line in sys.stdin:
        pattern1 = r'gene_[0-9]{1,5}_.{1,16}_[1-4]_[A-Za-z]+T?0?'       ## regular expression pattern to match gene names in rice_blast dir
        pattern2 = r'gene_[0-9]{1,5}_GCA[0-9]{9}\.[0-9]T?0?'           ## regular expression pattern to match gene names in wheat_blast dir
        new_line = line[:-1]      ## modified string will be stored here
        matches1 = re.findall(pattern1, line[:-1])    ## find all matches in the line
        matches2 = re.findall(pattern2, line[:-1])    ## find all matches in the line
        if len(matches1) != 0 and len(matches2) != 0:
            print("ERROR: both gene name regular expressions match line")
        elif len(matches1) != 0:
            matches = matches1
        else:
            matches = matches2
        for match in matches:   ## for each match, modify the gene name
            num = int(match.split("_")[1])      ## gene number
            code = f"{num:05d}"                 ## make the gene number into 5 digit code
            new_name = genome + "_" + code      ## new gene name
            new_line = new_line.replace(match, new_name)   ## replace the old gene name with new one in the line
        corrected.write(new_line + "\n")

