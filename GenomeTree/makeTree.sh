#!/bin/bash
#SBATCH --job-name=GenomeTree
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make high quality genome tree

cd /global/scratch/users/annen/GENOME_TREE

#source activate /global/scratch/users/annen/anaconda3/envs/Biopython
#echo "*** Processing proteomes ***"
#cat PROTEOMES/genome_list.txt | python /global/scratch/users/annen/KVKLab/GenomeTree/process_faa_for_orthofinder.py
#echo "*** Done ***"
#conda deactivate

### Run OrthoFinder
#source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder
#orthofinder -oa -f PROTEOMES_filt -t 24 -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -o OrthoFinder_out
#conda deactivate

### Align SCOs
#ls OrthoFinder_out/Results_Nov22/Single_Copy_Orthologue_Sequences/ | awk -v FS="." '{ print $1; }' | while read SCO; do
#    mafft --maxiterate 1000 --globalpair --thread 24 OrthoFinder_out/Results_Nov22/Single_Copy_Orthologue_Sequences/${SCO}.fa > SCO_alignments/${SCO}.afa
#    echo "${SCO} done"
#done

### Concatenate MSAs
#source activate /global/scratch/users/annen/anaconda3/envs/Biopython
#cat PROTEOMES/genome_list.txt | python /global/scratch/users/annen/KVKLab/GenomeTree/concat_msa.py
#conda deactivate

### Trim alignment
trimal -gt 0.8 -in ALL_SCOs.afa -out ALL_SCOs.trim.afa

### Make tree
echo "*** making fasttree ***"
fasttree -gamma < ALL_SCOs.trim.afa > ALL_SCOs.tree

echo "*** making RAxML tree ***"
#raxmlHPC-PTHREADS-SSE3 

