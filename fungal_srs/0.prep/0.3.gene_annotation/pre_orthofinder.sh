#!/bin/bash
#SBATCH --job-name=pre_orthofinder
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### prep the proteomes for orthogrouping by renaming genes in faa and gff files from fungap
### also process faa to remove stop codons

working_dir=${1}    # FUNGAP directory

cd ${working_dir}
mkdir -p ../ORTHOFINDER/FAA 
mkdir -p ../ORTHOFINDER/GFF 

while read genome; do
    ### rename faa file and genes in file, remove stop codons
    cat ${genome}/fungap_out/fungap_out/fungap_out_prot.faa | awk -v g=${genome} '/>/ { print ">" g substr($1,6,6); } !/>/ { print; }' | tr -d "*" > ../ORTHOFINDER/FAA/${genome}.faa
    ### rename gff file and genes in gff file (replace any "gene_" with the new_name)
    sed "s/gene\_/${new_name}\_/g" ${genome}/fungap_out/fungap_out/fungap_out.gff3 > ../ORTHOFINDER/GFF/${genome}.gff3
done < ../fungap_list.txt
