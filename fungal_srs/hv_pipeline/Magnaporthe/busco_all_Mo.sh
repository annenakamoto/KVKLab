#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoGENOMES_all

### download all M. oryzae genomes from NCBI + outgroups
# source activate /global/scratch/users/annen/anaconda3/envs/ncbi_datasets
# datasets download genome taxon 'Pyricularia oryzae' --include genome --assembly-source GenBank
# unzip ncbi_dataset.zip 
# mv ncbi_dataset/data/GCA_*/GCA_* .
# rm ncbi_dataset.zip rm README.md 
# rm -r ncbi_dataset/
# wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/004/355/905/GCA_004355905.1_PgNI/GCA_004355905.1_PgNI_genomic.fna.gz
# wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/004/337/975/GCA_004337975.1_PspLS/GCA_004337975.1_PspLS_genomic.fna.gz
# gunzip *.gz
# conda deactivate

cd /global/scratch/users/annen/000_FUNGAL_SRS_000

### run busco on all genomes in MoGENOMES_all
module purge    # loaded modules interfere with busco
source activate /global/scratch/users/annen/anaconda3/envs/busco
busco -i MoGENOMES_all -l sordariomycetes_odb10 -o BUSCO_allMo_out -m genome -c 24
conda deactivate
