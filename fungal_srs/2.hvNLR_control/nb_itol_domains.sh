#!/bin/bash
#SBATCH --job-name=tree_nb_domain
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### make a domain-based (NB-ARC, NACHT) tree

working_dir=${1}    ## NLR_CTRL dir
species=${2}        ## Mo, Zt, Sc, or Nc
DOM=${3}            ## NB-ARC or NACHT

cd ${working_dir}

module purge
module load hmmer

### generate fasta file of genes containing the domain
module load seqtk
cat ${species}.${DOM}.filt.F.afa | awk '/>/ { print substr($1,2); }' > ${species}.${DOM}.gene_list.txt
seqtk subseq -l 60 WD/${species}_PANPROTEOME.faa ${species}.${DOM}.gene_list.txt > ${species}.${DOM}.filt.F.fa

source activate /global/scratch/users/annen/anaconda3/envs/R
hmmsearch --cpu ${SLURM_NTASKS} --domtblout ${species}.${DOM}.Pfam.tbl WD/Pfam-A.hmm ${species}.${DOM}.filt.F.fa
tr -s ' ' < ${species}.${DOM}.Pfam.tbl > ${species}.${DOM}.Pfam.ws.tbl
Rscript /global/scratch/users/annen/KVKLab/fungal_srs/2.hvNLR_control/reduce_pfam.R -i ${species}.${DOM}.Pfam.ws.tbl -o ${species}.${DOM}.Pfam.reduced.tbl -e 0.001 -f 0.3 -a 10
source deactivate

source activate /global/scratch/users/annen/anaconda3/envs/Biopython
python /global/scratch/users/annen/KVKLab/fungal_srs/2.hvNLR_control/itol_domains.py ${species}.${DOM} ${species}.${DOM}.filt.F
source deactivate

