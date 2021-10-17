from Bio import pairwise2
from Bio import SeqIO
from Bio.Seq import Seq
import numpy as np
from Bio.pairwise2 import format_alignment
from tqdm import tqdm

import string

import matplotlib.pyplot as plt

from sklearn.cluster import SpectralClustering, KMeans

import numpy as np
import os
from os.path import isfile, join, dirname, isdir, exists

from os import path
from Bio import Align

import statistics
from statistics import mode


from sklearn.manifold import TSNE
from itertools import combinations

import seaborn as sns
import sys


def jc_dist(aln_str):
    G = aln_str.count('-')
    I = aln_str.count('|')
    fU = aln_str.count('.')
    T = G+I+fU
    return -3/4*np.log(1-4/3*(fU/(I+fU)))*(1 - G/T)+G/T                                      

aligner = Align.PairwiseAligner()

aligner.mode = 'global'     # should it be 'local' for TEs ? ('global')
aligner.match_score = 0
aligner.mismatch_score = -1
aligner.open_gap_score = -1
aligner.extend_gap_score = -1
aligner.target_end_gap_score = -1
aligner.query_end_gap_score = -1

def numseq(path):
    counter = 0
    for _ in SeqIO.parse(path, 'fasta'):
        counter += 1
    return counter

def make_dir(*argv):
    mydir = path.join(*argv)    
    if not path.exists(mydir):        
        if len(argv) > 1:
            make_dir(*argv[:-1])            
        os.mkdir(mydir)
    return mydir


def make_path(*argv):
    mypath = path.join(*argv)
    if not path.exists(dirname(mypath)):
        make_dir(*argv[:-1])
    return mypath


###     Usage: python JC_dist_ref.py <lib_fasta_path> <ref_fasta_path>
###     lib_fasta_path: path to fasta file containing many sequences
###     ref_fasta_path: path to fasta file containing one reference sequence

frags_path = sys.argv[1]    ### Arg1 is the path to the library fasta file
ref_path = sys.argv[2]      ### Arg2 is the path to the reference fasta file

def main():
    DIST = {}
    ref_iter = SeqIO.parse(ref_path, 'fasta')
    reference = ref_iter.next()
    for record in SeqIO.parse(frags_path, 'fasta'):                                  
        alignment = aligner.align(record.seq, reference.seq)[0]
        d = jc_dist(repr(str(alignment)).split('\\n')[1])
        DIST[record.name] = d
    print(reference.name)
    for key, value in DIST.items():
        print(key + '\t' + str(value))

### RUN
main()
