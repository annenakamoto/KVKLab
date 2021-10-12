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

aligner.mode = 'global'     # should it be 'local' for TEs ?
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


# usage: python jc_dist_BOYAN.py <num_seq> <fasta_path>

N = sys.argv[1]             ### Arg1 is the total number of sequences in fasta file
frags_path = sys.argv[2]    ### Arg2 is the path to fasta file

def main():
    #N is the total number of sequences in your file
    #frags_path is the path to a fasta file containing your sequences
    #X is an array whose ith row and jth column represent the jukes cantor distance between sequence i and sequence j
    X = np.zeros((int(N),int(N)))

    for (ii, record1), (jj, record2)  in tqdm(combinations(enumerate(SeqIO.parse(frags_path, 'fasta')), r = 2)):                                  
        alignment = aligner.align(record1.seq, record2.seq)[0]
        d = jc_dist(repr(str(alignment)).split('\\n')[1])
        X[ii, jj] = d
        X[jj, ii] = d
    
    print(X)

def main_dict():
    #N is the total number of sequences in your file
    #frags_path is the path to a fasta file containing your sequences
    #X is an array whose ith row and jth column represent the jukes cantor distance between sequence i and sequence j
    DIST = {}

    for (ii, record1), (jj, record2)  in tqdm(combinations(enumerate(SeqIO.parse(frags_path, 'fasta')), r = 2)):                                  
        alignment = aligner.align(record1.seq, record2.seq)[0]
        d = jc_dist(repr(str(alignment)).split('\\n')[1])
        DIST[(ii, jj)] = d
    
    for key, value in DIST:
        print(key + '\t' + value)


### RUN
main_dict()
