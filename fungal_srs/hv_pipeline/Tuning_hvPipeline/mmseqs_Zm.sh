#!/bin/bash
#SBATCH --job-name=mmseqs_Zm
#SBATCH --account=co_minium
#SBATCH --qos=savio_lowprio
#SBATCH --partition=savio2
#SBATCH --requeue
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=12:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/maize_NAM_proteomes

### Download proteomes of the 26 maize NAM lines
# while read link; do
#     wget ${link}
#     gunzip *.gz
# done < /global/scratch/users/annen/fungal_srs/hv_pipeline/Tuning_hvPipeline/download_list.txt    # text file containing protein fasta FTP links

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

### Combine all 26 maize NAM proteomes into one pan-proteome, keeping only genes with P001 suffix (filter out all other alternative transcripts)
# cat maize_NAM_proteomes/*protein.fa | awk -v RS=">" '/P001/ { print ">" substr($0, 1, length($0)-1); }' > Zm_panPROTEOME.fa

### Run MMSeqs2 on the filtered pan-proteome
conda activate MMseqs2
echo "*** creating mmseqs database ***"
mmseqs createdb Zm_panPROTEOME.fa Zm_panPROTEOME                                            # convert fasta file to MMseqs2 database format
echo "*** running mmseqs linclust ***"
mmseqs linclust Zm_panPROTEOME Zm_panPROTEOME_clu tmp --cov-mode 0 -c 0.5                   # run the linear clustering algorithm on the database
echo "*** producing msa to center sequence ***"
mmseqs result2msa Zm_panPROTEOME Zm_panPROTEOME Zm_panPROTEOME_clu Zm_panPROTEOME_clu_msa   # produce an MSA to center sequence (pseudo alignment)
conda deactivate

### download Maize_NLRome_GeneTable.txt
# wget https://github.com/daniilprigozhin/NLRCladeFinder/raw/main/Maize_NLRome/Maize_NLRome_GeneTable.txt



