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
source activate /global/scratch/users/annen/anaconda3/envs/treeKO

### process the genome and gene trees to be formatted properly for TreeKO
###     want only the genes from the representative genomes
###     first 3 letters of the name of each leaf should indicate the "species" (genome)
path_to_OF_genome_tree="/global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Species_Tree/SpeciesTree_rooted.txt"
path_to_OF_gene_trees="/global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Gene_Trees"

# prune genome tree
cat ${path_to_OF_genome_tree} | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/prune_genome_tree.py "guy11 US71 B71 LpKY97 MZ5-1-6 NI907" > OF_RENAMED/GenomeTree.txt

> gene_tree_list.txt
ls ${path_to_OF_gene_trees} | while read OG; do
    # Keeps only the leaves of the specified species
    cat ${path_to_OF_gene_trees}/${OG} | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/prune_gene_tree.py "guy11 US71 B71 LpKY97 MZ5-1-6 NI907" > OF_RENAMED/${OG}
    echo "OF_RENAMED/${OG}" >> gene_tree_list.txt
done

genome_tree="OF_RENAMED/GenomeTree.txt" # path to genome tree to use for treeKO
gene_tree_list="gene_tree_list.txt"   # text file with list of paths to the gene trees

### create the config file for TreeKO
> config_file.txt
echo -e "orto_mode\ts" >> config_file.txt   # s: Orthology and paralogy nodes will be predicted using the species overlap algorithm
echo -e "root_method\ts" >> config_file.txt # s: root at a user defined species or protein
echo -e "root_species\tNI9" >> config_file.txt  # specify the species to root trees at
echo -e "print_strict_distance" >> config_file.txt  # only print strict distance

### run TreeKO
python /global/scratch/users/annen/treeKO/treeKo.py -p tc -a ${genome_tree} -l ${gene_tree_list} -c config_file.txt -o treeKO_output.txt
conda deactivate
