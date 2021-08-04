#!/bin/bash
#SBATCH --job-name=tree_msa
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=96:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/

TE=$1   # RepBase element (ex. MAGGY)
mode=$2 # normal or representative or rep-root

# create represenative RepBase element-specific library (ex. MAGGY library)
# te_spec_lib.py reads from LIB_DOM.fasta.classified (nucleotide)

### NORMAL
if [ $mode == "normal" ]; then
    #cat MAFFT_out/tree_${TE}.txt | awk ' BEGIN { FS="#" } { gsub(/ /, "_"); print $1 "#" $2 ; }' | python KVKLab/Phase1/te_spec_lib.py > MAFFT_out/LIB_DOM_${TE}.fasta
    #echo "created seq library for ${TE}"
    cd /global/scratch/users/annen/MAFFT_out
    #mafft LIB_DOM_${TE}.fasta > ${TE}_aligned.afa
    #echo "completed MSA for ${TE}"
    raxml -T 24 -n Raxml_${TE}.out -f a -x 12345 -p 12345 -# 100 -m GTRCAT -s ${TE}_aligned.afa
    echo "ran RAXML for ${TE}"
fi
### REPRESENTATIVE
if [ $mode == "representative" ]; then
    cat MAFFT_out/tree_${TE}.txt | awk ' BEGIN { FS="#" } /MAGGY/||/GYMAG1/||/GYMAG2/||/GYPSY1/||/MGRL3/||/PYRET/||/MGR583/||/POT2/||/guy11/||/US71/||/B71/||/MZ5-1-6/||/LpKY97/||/Lh88405/ { gsub(/ /, "_"); print $1 "#" $2 ; }' | python KVKLab/Phase1/te_spec_lib.py > MAFFT_out/LIB_DOM_${TE}_rep.fasta
    echo "created seq library for ${TE}"
    cd /global/scratch/users/annen/MAFFT_out
    mafft LIB_DOM_${TE}_rep.fasta > ${TE}_aligned_rep.afa
    echo "completed MSA for ${TE}"
    raxml -T 24 -n Raxml_${TE}_rep.out -f a -x 12345 -p 12345 -# 100 -m GTRCAT -s ${TE}_aligned_rep.afa
    echo "ran RAXML for ${TE}"
fi
### REP-ROOT <ROOT>
if [ $mode == "rep-root" ]; then
    root=$3
    cat MAFFT_out/tree_${TE}.txt | awk ' BEGIN { FS="#" } /MAGGY/||/GYMAG1/||/GYMAG2/||/GYPSY1/||/MGRL3/||/PYRET/||/MGR583/||/POT2/||/guy11/||/US71/||/B71/||/MZ5-1-6/||/LpKY97/||/Lh88405/ { gsub(/ /, "_"); print $1 "#" $2 ; }' > MAFFT_out/tree_${TE}_root.txt
    echo $root >> MAFFT_out/tree_${TE}_root.txt
    cat MAFFT_out/tree_${TE}_root.txt | python KVKLab/Phase1/te_spec_lib.py > MAFFT_out/LIB_DOM_${TE}_root.fasta
    echo "created seq library for ${TE}"
    cd /global/scratch/users/annen/MAFFT_out
    mafft LIB_DOM_${TE}_root.fasta > ${TE}_aligned_root.afa
    echo "completed MSA for ${TE}"
    raxml -T 24 -n Raxml_${TE}_root.out -f a -x 12345 -p 12345 -# 100 -m GTRCAT -s ${TE}_aligned_root.afa
    echo "ran RAXML for ${TE}"
fi
