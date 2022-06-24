#!/bin/bash
#SBATCH --job-name=treeKO
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Use TreeKO to determine the strict distance between the genome tree and each gene tree

cd /global/scratch/users/annen/treeKO_analysis
module unload python
# echo "*** activating treeKO conda env ***"
# source activate /global/scratch/users/annen/anaconda3/envs/treeKO
# echo "*** activated ***"

### process the genome and gene trees to be formatted properly for TreeKO
###     want only the genes from the representative genomes
###     first 3 letters of the name of each leaf should indicate the "species" (genome)
# path_to_OF_genome_tree="/global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Species_Tree/SpeciesTree_rooted.txt"
# path_to_OF_gene_trees="/global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Gene_Trees"

# prune genome tree
# echo "*** prune the genome tree ***"
# cat ${path_to_OF_genome_tree} | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/prune_genome_tree.py "guy11 US71 B71 LpKY97 MZ5-1-6 NI907" > OF_RENAMED/GenomeTree.txt
# echo "*** done ***"

# ls ${path_to_OF_gene_trees} | while read OG; do
#     # Keeps only the leaves of the specified species
#     cat ${path_to_OF_gene_trees}/${OG} | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/prune_gene_tree.py "guy11 US71 B71 LpKY97 MZ5-1-6 NI907" > OF_RENAMED/${OG}
#     if [ -s OF_RENAMED/${OG} ]; then
#         echo "*** pruned ${OG} ***"
#     else    # remove pruned tree file if empty and don't add to list
#         rm OF_RENAMED/${OG}
#         echo "*** pruned ${OG}, now empty, removing ***"
#     fi
# done
# echo "*** done pruning ***"
# conda deactivate

### root the trees using the min variance option of FastRoot
# > gene_tree_list.txt
# source activate /global/scratch/users/annen/anaconda3/envs/MinVar-Rooting
# ls OF_RENAMED | while read TREE; do
#     #python3 /global/scratch/users/annen/MinVar-Rooting-master/FastRoot.py -i OF_RENAMED/${TREE} -m MV -o ROOTED/${TREE}
#     if [ -s ROOTED/${TREE} ]; then
#         echo "ROOTED/${TREE}" >> gene_tree_list.txt
#         echo "*** rooted ${TREE} ***"
#     else
#         rm ROOTED/${TREE}
#         echo "*** couldn't root ${TREE}, removing ***" # these trees only have one leaf
#     fi
# done
# conda deactivate

genome_tree="ROOTED/GenomeTree.txt" # path to genome tree to use for treeKO
gene_tree_list="gene_tree_list.txt"   # text file with list of paths to the gene trees

### create the config file for TreeKO
# > config_file.txt
# echo -e "root_method1\tn" >> config_file.txt # n: tree is already rooted
# echo -e "root_method2\tn" >> config_file.txt # n: tree is already rooted
# echo -e "print_oneline" >> config_file.txt  # prints output in one line per tree, easier to parse

### run TreeKO
# echo "*** starting treeKO ***"
# source activate /global/scratch/users/annen/anaconda3/envs/treeKO
# python /global/scratch/users/annen/treeKO/treeKO.py -p tc -a ${genome_tree} -l ${gene_tree_list} -o treeKO_output.txt -c config_file.txt 
# echo "*** treeKO done ***"
# conda deactivate

### parse treeKO output into tabular format
echo "*** parsing treeKO data to tabular format ***"
cat treeKO_output.txt | awk -v OFS='\t' '/Results/ { print substr($3, 8, 9), $4 }' > treeKO_output_table.txt

### group data by SCOs (need OG names that are SCOs)
> SCO.strict_d.txt
cat /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | while read OG; do
    grep ${OG} treeKO_output_table.txt >> SCO.strict_d.txt
done

### group data by effectors (need OG names containing predicted effectors)
ls /global/scratch/users/annen/Effector_analysis/*_effector_protein_names | while read list; do
    file_name=$(basename ${list})
    genome=$(echo ${file_name} | awk -v FS='_' '{ print $1 }')
    > EFFs.${genome}.strict_d.txt
    cat ${list} | while read gene; do
        OG=$(grep ${gene} GENOME_TREE/OrthoFinder_out/Results_Jun21/Orthogroups/Orthogroups.txt | awk '{ print substr($1, 1, 9) }')
        grep ${OG} treeKO_output_table.txt >> EFFs.${genome}.strict_d.txt
    sort EFFs.${genome}.strict_d.txt | uniq > EFF.${genome}.strict_d.txt
    rm EFFs.${genome}.strict_d.txt

echo "*** DONE ***"
