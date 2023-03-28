#!/bin/bash
#SBATCH --job-name=cleanup_fungap
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoFunGAP

> tmp_rm_list.sh
echo GCA_001548775.1 >> tmp_rm_list.sh
echo GCA_001548785.1 >> tmp_rm_list.sh
echo GCA_002925165.1 >> tmp_rm_list.sh
echo GCA_002925415.1 >> tmp_rm_list.sh
echo GCA_021442365.1 >> tmp_rm_list.sh
echo GCA_024703655.1 >> tmp_rm_list.sh
echo GCA_024703665.1 >> tmp_rm_list.sh
echo GCA_024703685.1 >> tmp_rm_list.sh
echo GCA_024703975.1 >> tmp_rm_list.sh
echo GCA_024704035.1 >> tmp_rm_list.sh
echo GCA_024704055.1 >> tmp_rm_list.sh
echo GCA_024704115.1 >> tmp_rm_list.sh
echo GCA_024704165.1 >> tmp_rm_list.sh
echo GCA_024704315.1 >> tmp_rm_list.sh
echo GCA_024704445.1 >> tmp_rm_list.sh
echo GCA_024704475.1 >> tmp_rm_list.sh
echo GCA_024704485.1 >> tmp_rm_list.sh
echo GCA_024704505.1 >> tmp_rm_list.sh
echo GCA_024704605.1 >> tmp_rm_list.sh
echo GCA_024704625.1 >> tmp_rm_list.sh
echo GCA_024704655.1 >> tmp_rm_list.sh
echo GCA_024704695.1 >> tmp_rm_list.sh
echo GCA_024704685.1 >> tmp_rm_list.sh

while read GCA; do
    if [ -f "${GCA}/fungap_out/fungap_out/fungap_out.gff3" ]; then
        echo "${GCA}: fungap finished, removing dirs to make space"
        rm -r ${GCA}/busco_downloads
        rm -r ${GCA}/fungap_out/augustus_out  ${GCA}/fungap_out/braker_out  ${GCA}/fungap_out/busco_out  ${GCA}/fungap_out/gene_filtering 
        rm -r ${GCA}/fungap_out/hisat2_out  ${GCA}/fungap_out/maker_out  ${GCA}/fungap_out/repeat_modeler_out  ${GCA}/fungap_out/trinity_out
    fi
done < /global/scratch/users/annen/000_FUNGAL_SRS_000/MoFunGAP/tmp_rm_list.sh
