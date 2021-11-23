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
#trimal -gt 1 -in ALL_SCOs.afa -out ALL_SCOs.trim.afa

### Make tree
#echo "*** making fasttree ***"
#source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder
#fasttree -gamma < ALL_SCOs.trim.afa > ALL_SCOs.tree
#conda deactivate

#echo "*** making raxmlHPC-PTHREADS-SSE3 tree ***"
#raxmlHPC-PTHREADS-SSE3 -s ALL_SCOs.trim.afa -n RAxML.ALL_SCOs -m PROTGAMMAGTR -T 24 -f a -x 12345 -p 12345 -# 100


### Benchmarking other RAxML versions

#echo "*** making raxmlHPC  tree ***"
#raxmlHPC -s ALL_SCOs.trim.afa -n raxmlHPC.ALL_SCOs -m PROTGAMMAGTR -f a -x 12345 -p 12345 -# 100

#echo "*** making raxmlHPC-MPI-SSE3 tree ***"
#raxmlHPC-MPI-SSE3 -s ALL_SCOs.trim.afa -n raxmlHPC-MPI-SSE3.ALL_SCOs -m PROTGAMMAGTR -f a -x 12345 -p 12345 -# 100

#echo "*** making raxmlHPC-SSE3 tree ***"
#raxmlHPC-SSE3 -s ALL_SCOs.trim.afa -n raxmlHPC-SSE3.ALL_SCOs -m PROTGAMMAGTR -f a -x 12345 -p 12345 -# 100

#echo "*** making raxmlHPC-HYBRID-SSE3 tree ***"
#raxmlHPC-HYBRID-SSE3 -s ALL_SCOs.trim.afa -n raxmlHPC-HYBRID-SSE3.ALL_SCOs -m PROTGAMMAGTR -T 24 -f a -x 12345 -p 12345 -# 100

echo "*** making raxmlHPC-SSE3-QUARTET-MPI tree ***"
raxmlHPC-SSE3-QUARTET-MPI -s ALL_SCOs.trim.afa -n raxmlHPC-SSE3-QUARTET-MPI.ALL_SCOs -m PROTGAMMAGTR -f a -x 12345 -p 12345 -# 100

