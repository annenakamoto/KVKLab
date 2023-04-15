from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import sys
import os

### STDIN: list of genome names
### works when in /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder

msa_dir = sys.argv[1]   # directory containing the msas to concatenate
out_file = sys.argv[2]  # file to output concatenated alignment to (.afa)

GENOMES = {}
for line in sys.stdin:
    g = line[:-1]
    GENOMES[g] = SeqRecord(Seq(""), g, '', '')

msa_list = os.listdir(msa_dir)
for msa in msa_list:
    msa_path =  msa_dir + "/" + msa
    for record in SeqIO.parse(msa_path, 'fasta'):
        genome = record.id
        GENOMES[genome].seq += record.seq

with open(out_file, 'w') as handle:
    for seq in GENOMES.values():
        SeqIO.write(seq, handle, 'fasta')
