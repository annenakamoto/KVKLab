#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

ls OrthoFinder_out/Results_Mar16/MultipleSequenceAlignments | while read fa; do
    cons -sequence OrthoFinder_out/Results_Mar16/MultipleSequenceAlignments/${fa} -outseq OG_CONS/${fa} -name ${fa%.*}
done

cat OG_CONS/* > OG_Consenses.fa

source activate /global/scratch/users/annen/anaconda3/envs/MMseqs2
echo "*** creating mmseqs database ***"
mmseqs createdb OG_Consenses.fa OG_Consenses                                           # convert fasta file to MMseqs2 database format
echo "*** running mmseqs linclust ***"
mmseqs linclust OG_Consenses OG_Consenses_clu tmp --cov-mode 0 -c 0.5    # run the linear clustering algorithm on the database
echo "*** make tsv of clusters ***"
mmseqs createtsv OG_Consenses OG_Consenses OG_Consenses_clu OG_Consenses_clu.tsv    # make tsv to more easily view clusters
conda deactivate
