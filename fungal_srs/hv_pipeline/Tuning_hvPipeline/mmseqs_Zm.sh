#!/bin/bash
#SBATCH --job-name=mmseqs_Zm
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

COV=$1  # takes MMseqs coverage argument [0,99]

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/maize_NAM_proteomes

### Download proteomes of the 26 maize NAM lines
# while read link; do
#     wget ${link}
#     gunzip *.gz
# done < /global/scratch/users/annen/fungal_srs/hv_pipeline/Tuning_hvPipeline/download_list.txt    # text file containing protein fasta FTP links

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

### Combine all 26 maize NAM proteomes into one pan-proteome, keeping only genes with P001 suffix (filter out all other alternative transcripts)
rm Zm_panPROTEOME*
cat maize_NAM_proteomes/*protein.fa | awk -v RS=">" '/P001/ { print ">" substr($0, 1, length($0)-1); }' > Zm_panPROTEOME.fa

### Run MMSeqs2 on the filtered pan-proteome
source activate /global/scratch/users/annen/anaconda3/envs/MMseqs2
echo "*** creating mmseqs database ***"
mmseqs createdb Zm_panPROTEOME.fa Zm_panPROTEOME                                            # convert fasta file to MMseqs2 database format
echo "*** running mmseqs linclust ***"
mmseqs linclust Zm_panPROTEOME Zm_panPROTEOME_clu tmp --cov-mode 0 -c 0.${COV}                   # run the linear clustering algorithm on the database
echo "*** producing msa to center sequence ***"
mmseqs result2msa Zm_panPROTEOME Zm_panPROTEOME Zm_panPROTEOME_clu Zm_panPROTEOME_clu_msa   # produce an MSA to center sequence (pseudo alignment)
echo "*** make tsv of clusters ***"
mmseqs createtsv Zm_panPROTEOME Zm_panPROTEOME Zm_panPROTEOME_clu Zm_panPROTEOME_clu.tsv    # make tsv to more easily view clusters
source deactivate

### download Maize_NLRome_GeneTable.txt
# wget https://github.com/daniilprigozhin/NLRCladeFinder/raw/main/Maize_NLRome/Maize_NLRome_GeneTable.txt

### parse Maize_NLRome_GeneTable.txt and Zm_panPROTEOME_clu.tsv, then check for broken clades
python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/check_clades.py > check_clades_REPORT_c${COV}.txt

