from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import sys
import os

### STDIN: list of genome names (PROTEOMES/genome_list.txt)
### works when in /global/scratch/users/annen/GENOME_TREE

GENOMES = {}
for line in sys.stdin:
    g = line[:-1]
    GENOMES[g] = SeqRecord(Seq(""), g, '', '')

msa_list = os.listdir("SCO_ALIGNMENTS")
for msa in msa_list:
    msa_path =  "SCO_ALIGNMENTS/" + msa
    for record in SeqIO.parse(msa_path, 'fasta'):
        genome = record.id.split(":")[0].split("_")[1]
        GENOMES[genome].seq += record.seq

with open("ALL_SCOs_nuc.afa", 'w') as handle:
    for seq in GENOMES.values():
        SeqIO.write(seq, handle, 'fasta')

