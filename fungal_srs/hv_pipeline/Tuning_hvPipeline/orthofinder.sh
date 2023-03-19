#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/maize_NAM_proteomes

# ls *.protein.fa | while read fa; do
#     cat ${fa} | awk -v RS=">" '/P001/ { print ">" substr($0, 1, length($0)-1); }' > /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/OrthoFinder_in/${fa}
# done

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

### Run OrthoFinder on maize NAM proteomes
# module purge
# rm -r OrthoFinder_out
# source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder
# orthofinder -oa -f OrthoFinder_in -t 24 -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -X -o OrthoFinder_out
# conda deactivate

### check orthogroups, were any clades from Maize_NLRome_GeneTable.txt broken?
# python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/check_ogs.py > check_OGs_REPORT.txt

### download Pfam library (Pfam-A.hmm and Pfam-A.dat)
cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/Pfam_lib
# wget http://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam35.0/Pfam-A.hmm.gz
# wget http://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam35.0/Pfam-A.hmm.dat.gz
# gunzip *.gz
# hmmpress Pfam-A.hmm

### run pfam_scan to determine domain architecture for each OG
cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline
# source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
# PARA="$1"
# ls OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${PARA} | while read fa; do
#     og=$(basename "${fa}")
#     echo ${og}
#     pfam_scan.pl -fasta OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${og} -dir Pfam_lib -e_dom 0.01 -e_seq 0.01 -outfile Pfam_Scan_out/${og}.pfamscan.out
# done
# source deactivate

### parse each pfam_scan output file for domain architecture of the OG
ls Pfam_Scan_out | while read ps; do
    og=$(echo ${ps} | awk -v FS="." '{ print $1; }')
    num=$(grep -c ">" OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${og}.fa)
    echo ${og}
    ### python script that outputs the line: OG, num_genes_in_OG, num_total_pfamscan_hits, percent_genes_with_common_arch, most_common_domarch, set_of_all_domains_in_OG_and_counts
    cat ls Pfam_Scan_out/${ps} | python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/dom_arch.py ${og} ${num} > Domain_Arch/${og}.domarch.txt
done

