#!/bin/bash
#SBATCH --job-name=pfam_dom_arch
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### download Pfam library (Pfam-A.hmm and Pfam-A.dat)
cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder
# cp /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/Pfam_lib/* Pfam_lib

### run pfam_scan to determine domain architecture for each OG
cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder
mkdir -p Pfam_Scan_out
source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
part=${1}   # 000, 001, etc; 01 to 18
ls OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences/OG00${part}* | while read fa; do
    og=$(basename "${fa}")
    if [ -f "Pfam_Scan_out/${og}.pfamscan.out" ]; then
        echo "${og} already done"
    else
        echo "Running pfam_scan for ${og}"
        pfam_scan.pl -fasta OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences/${og} -dir Pfam_lib -e_dom 0.01 -e_seq 0.01 -outfile Pfam_Scan_out/${og}.pfamscan.out
        echo "${og} done"
    fi
done
source deactivate

### parse each pfam_scan output file for domain architecture of the OG
# mkdir -p Domain_Arch
# > Domain_Arch/OG_domarch.REPORT.txt
# ls Pfam_Scan_out | while read ps; do
#     og=$(echo ${ps} | awk -v FS="." '{ print $1; }')
#     num=$(grep -c ">" OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences/${og}.fa)
#     echo ${og}
#     ### python script that outputs the line: OG, num_genes_in_OG, num_total_pfamscan_hits, percent_genes_with_common_arch, most_common_domarch, set_of_all_domains_in_OG_and_counts
#     cat Pfam_Scan_out/${ps} | python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/dom_arch.py ${og} ${num} >> Domain_Arch/OGs_domarch.REPORT.txt
# done

### parse Domain_Arch/OG_domarch.REPORT.txt for 1) a list of domains and the count and 2) a list of domain archs and their count, both ordered greatest to least
# cat Domain_Arch/OGs_domarch.REPORT.txt | python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/common_dom.py > Domain_Arch/Common_Domains.REPORT.txt
# cat Domain_Arch/OGs_domarch.REPORT.txt | python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/common_arch.py > Domain_Arch/Common_Archs.REPORT.txt
