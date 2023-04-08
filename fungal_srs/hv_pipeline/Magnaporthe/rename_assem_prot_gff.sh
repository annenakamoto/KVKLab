#!/bin/bash
#SBATCH --job-name=rename
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen
source activate /global/scratch/users/annen/anaconda3/envs/Biopython

### rename assemblies
###     NCBI assemblies (includes outgroups)
# cat KVKLab/fungal_srs/hv_pipeline/Magnaporthe/renaming_tbl.txt | awk '/GCA_/' | while read line; do
#     gca=$(echo ${line} | awk '{ print $2; }')
#     new_name=$(echo ${line} | awk '{ print $8; }')
#     cp 000_FUNGAL_SRS_000/MoGENOMES_all/${gca}*genomic.fna 000_FUNGAL_SRS_000/MoOrthoFinder/MoASSEMBLIES/${new_name}.fna
# done
###     assemblies not from NCBI
# cat KVKLab/fungal_srs/hv_pipeline/Magnaporthe/renaming_tbl.txt | awk '$2 ~ "None"' | while read line; do
#     iso=$(echo ${line} | awk '{ print $3; }')
#     new_name=$(echo ${line} | awk '{ print $8; }')
#     cp 000_FUNGAL_SRS_000/MoGENOMES_not_on_NCBI/${iso}.fasta 000_FUNGAL_SRS_000/MoOrthoFinder/MoASSEMBLIES/${new_name}.fna
# done


### rename proteomes and gff, + their genes
###     my old annotations
# cat KVKLab/fungal_srs/hv_pipeline/Magnaporthe/renaming_tbl.txt | awk '$1 ~ "anne_old"' | while read line; do
#     iso=$(echo ${line} | awk '{ print $3; }')
#     lin=$(echo ${line} | awk '{ print $4; }')
#     new_name=$(echo ${line} | awk '{ print $8; }')
#     if [ "${lin}" = "MoO" ]; then
#         p="oryza"
#     elif [ "${lin}" = "MoS" ]; then
#         p="setaria"
#     elif [ "${lin}" = "MoT" ]; then
#         p="triticum"
#     elif [ "${lin}" = "MoL" ]; then
#         p="lolium"
#     elif [ "${lin}" = "MoE" ]; then
#         p="eleusine"
#     fi
#     old_faa=FunGAP_out/${p}/${iso}/fungap_out/fungap_out_prot.faa
#     new_faa=000_FUNGAL_SRS_000/MoOrthoFinder/MoPROTEOMES/${new_name}.processed.faa
#     old_gff=FunGAP_out/${p}/${iso}/fungap_out/fungap_out.gff3
#     new_gff=000_FUNGAL_SRS_000/MoOrthoFinder/MoPROTEINGFF3/${new_name}.processed.gff3
#     # process faa (change gene names, remove stop codons)
#     python KVKLab/fungal_srs/hv_pipeline/Magnaporthe/process_faa_for_orthofinder.py ${new_name} ${old_faa} ${new_faa}
#     # process gff3 files by replacing any "gene_" with the new_name
#     sed "s/gene\_/${new_name}\_/g" ${old_gff} > ${new_gff}
# done
###     my new annotations
# cat KVKLab/fungal_srs/hv_pipeline/Magnaporthe/renaming_tbl.txt | awk '$1 ~ "anne_new"' | while read line; do
#     gca=$(echo ${line} | awk '{ print $2; }')
#     new_name=$(echo ${line} | awk '{ print $8; }')
#     old_faa=000_FUNGAL_SRS_000/MoFunGAP/${gca}/fungap_out/fungap_out/fungap_out_prot.faa
#     new_faa=000_FUNGAL_SRS_000/MoOrthoFinder/MoPROTEOMES/${new_name}.processed.faa
#     old_gff=000_FUNGAL_SRS_000/MoFunGAP/${gca}/fungap_out/fungap_out/fungap_out.gff3
#     new_gff=000_FUNGAL_SRS_000/MoOrthoFinder/MoPROTEINGFF3/${new_name}.processed.gff3
#     # process faa (change gene names, remove stop codons)
#     python KVKLab/fungal_srs/hv_pipeline/Magnaporthe/process_faa_for_orthofinder.py ${new_name} ${old_faa} ${new_faa}
#     # process gff3 files by replacing any "gene_" with the new_name
#     sed "s/gene\_/${new_name}\_/g" ${old_gff} > ${new_gff}
# done
###     pierre's annotations
cat KVKLab/fungal_srs/hv_pipeline/Magnaporthe/renaming_tbl.txt | awk '$1 ~ "pierre"' | while read line; do
    iso=$(echo ${line} | awk '{ print $3; }')
    gca=$(echo ${line} | awk '{ print $2; }')
    new_name=$(echo ${line} | awk '{ print $8; }')
    old_faa=analysis_files_Pierre_PAV/genome_annotation/rice_blast/all_proteomes_corrected/${iso}*fungap_out_prot_filtered.faa
    if [ ! -f "${old_faa}" ]; then
        old_faa=analysis_files_Pierre_PAV/genome_annotation/wheat_blast/all_proteomes_corrected/${gca}*fungap_out_prot_filtered.faa
    fi
    new_faa=000_FUNGAL_SRS_000/MoOrthoFinder/MoPROTEOMES/${new_name}.processed.faa
    old_gff=analysis_files_Pierre_PAV/genome_annotation/*_blast/all_proteomes_corrected/${iso}*fungap_out_prot_filtered.faa
    new_gff=000_FUNGAL_SRS_000/MoOrthoFinder/MoPROTEINGFF3/${new_name}.processed.gff3
    # process faa (change gene names, remove stop codons)
    python KVKLab/fungal_srs/hv_pipeline/Magnaporthe/process_faa_for_orthofinder_PIERR.py ${new_name} ${old_faa} ${new_faa}
    # process gff3 files to have same gene names as faa
    cat ${old_gff} | python KVKLab/fungal_srs/hv_pipeline/Magnaporthe/process_gff3_PIERR.py ${new_name} ${new_gff}
done
###     refseq annotations for outgroups (just need proteome, not gff)
# cat KVKLab/fungal_srs/hv_pipeline/Magnaporthe/renaming_tbl.txt | awk '$1 ~ "refseq"' | while read line; do
#     gca=$(echo ${line} | awk '{ print $2; }')
#     new_name=$(echo ${line} | awk '{ print $8; }')
#     old_faa=000_FUNGAL_SRS_000/MoOUTGROUPS/${gca}_*_protein.faa
#     new_faa=000_FUNGAL_SRS_000/MoOrthoFinder/MoPROTEOMES/${new_name}.processed.faa
#     # process faa (change gene names, remove stop codons)
#     python KVKLab/fungal_srs/hv_pipeline/Magnaporthe/process_faa_for_orthofinder_OUTGRP.py ${new_name} ${old_faa} ${new_faa}
# done

conda deactivate
