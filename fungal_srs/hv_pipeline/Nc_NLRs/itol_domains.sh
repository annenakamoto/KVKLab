#!/bin/bash
#SBATCH --job-name=Nc_itol_domains
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=9:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/333_NEUROSPORA_GS_MTK_333/RefGenome_NC12_NLRs

DOM=${1}     ## specify which domain (NB-ARC, NACHT, AAA)

module purge
module load hmmer

### generate fasta file of genes containing the domain
module load seqtk
> ${DOM}.gene_list.txt
cat Nc_${DOM}.filt.final.afa | awk -v FS="|" '/>/ { print substr($1,2); }' | while read gene; do
    grep ${gene} Nc_OR74A_PROTEOME.fa | awk '{ print substr($1,2); }' >> ${DOM}.gene_list.txt
done
seqtk subseq -l 60 Nc_OR74A_PROTEOME.fa ${DOM}.gene_list.txt > Nc_${DOM}.filt.final.fa

source activate /global/scratch/users/annen/anaconda3/envs/R
hmmsearch --domtblout ${DOM}.Pfam.tbl Pfam-A.hmm Nc_${DOM}.filt.final.fa
tr -s ' ' <${DOM}.Pfam.tbl > ${DOM}.Pfam.ws.tbl
Rscript ../../../ProteinFamily/scripts/reduce_pfam.R -i ${DOM}.Pfam.ws.tbl -o ${DOM}.Pfam.reduced.tbl -e 0.01 -f 0.1 -a 10
source deactivate

source activate /global/scratch/users/annen/anaconda3/envs/Biopython
python ../../../KVKLab/fungal_srs/hv_pipeline/Mo_NBARC_NACHT_AAA/itol_domains.py ${DOM} Nc_${DOM}.filt.final
source deactivate
