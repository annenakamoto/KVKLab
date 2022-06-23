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
echo "*** activating treeKO conda env ***"
source activate /global/scratch/users/annen/anaconda3/envs/treeKO
echo "*** activated ***"

### process the genome and gene trees to be formatted properly for TreeKO
###     want only the genes from the representative genomes
###     first 3 letters of the name of each leaf should indicate the "species" (genome)
path_to_OF_genome_tree="/global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Species_Tree/SpeciesTree_rooted.txt"
path_to_OF_gene_trees="/global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Gene_Trees"

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
conda deactivate

### root the trees using the min variance option of FastRoot
> gene_tree_list.txt
source activate /global/scratch/users/annen/anaconda3/envs/MinVar-Rooting
ls OF_RENAMED | while read TREE; do
    #python3 /global/scratch/users/annen/MinVar-Rooting-master/FastRoot.py -i OF_RENAMED/${TREE} -m MV -o ROOTED/${TREE}
    if [ -s ROOTED/${TREE} ]; then
        echo "ROOTED/${TREE}" >> gene_tree_list.txt
        #echo "*** rooted ${TREE} ***"
    else
        rm ROOTED/${TREE}
        echo "*** couldn't root ${TREE}, removing ***"
    fi
done
conda deactivate

genome_tree="ROOTED/GenomeTree.txt" # path to genome tree to use for treeKO
gene_tree_list="gene_tree_list.txt"   # text file with list of paths to the gene trees

### create the config file for TreeKO
#> config_file.txt
#echo -e "orto_mode\ts" >> config_file.txt   # s: Orthology and paralogy nodes will be predicted using the species overlap algorithm
#echo -e "root_method\tm" >> config_file.txt # s: root at the midpoint
#echo -e "root_species\tNI9" >> config_file.txt  # specify the species to root trees at
#echo -e "print_strict_distance" >> config_file.txt  # only print strict distance
#echo -e "print_all" >> config_file.txt

### run TreeKO
echo "*** starting treeKO ***"
python /global/scratch/users/annen/treeKO/treeKO.py -p tc -a ${genome_tree} -l ${gene_tree_list} -o treeKO_output.txt # -c config_file.txt 
echo "*** treeKO done ***"
conda deactivate
echo "*** DONE ***"
