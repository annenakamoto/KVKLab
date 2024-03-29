#!/bin/bash
#SBATCH --job-name=raxml_NBARC_NACHT_AAA
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=9:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder/NBARC_NACHT_AAA_hvAnalysis

DOM=${1}     ## specify which domain (NB-ARC, NACHT, AAA)

module purge
module load hmmer

### generate fasta file of genes containing the domain
module load seqtk
cat ${DOM}.Mo.filt.afa | awk '/>/ { print $4; }' > ${DOM}.gene_list.txt
seqtk subseq -l 60 MoPANPROTEOME_72.fa ${DOM}.gene_list.txt > ${DOM}.Mo.filt.fa

source activate /global/scratch/users/annen/anaconda3/envs/R
hmmsearch --cpu ${SLURM_NTASKS} --domtblout ${DOM}.Pfam.tbl Pfam-A.hmm ${DOM}.Mo.filt.fa
tr -s ' ' <${DOM}.Pfam.tbl > ${DOM}.Pfam.ws.tbl
Rscript ../../../ProteinFamily/scripts/reduce_pfam.R -i ${DOM}.Pfam.ws.tbl -o ${DOM}.Pfam.reduced.tbl -e 0.01 -f 0.1 -a 10
source deactivate

source activate /global/scratch/users/annen/anaconda3/envs/Biopython
python ../../../KVKLab/fungal_srs/hv_pipeline/Mo_NBARC_NACHT_AAA/itol_domains.py ${DOM} ${DOM}.Mo.filt
source deactivate
