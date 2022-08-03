#!/bin/bash
#SBATCH --job-name=visualize_TEs
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make trees for the POT2 toplology region

cd /global/scratch/users/annen

### make bed files for each of the above lines
# echo -e "CM015706.1\t689887\t1308036\tsec1_B71\t0\t+" > POT2_topo_region/sec1_B71.bed
# echo -e "CM015706.1\t277197\t316758\tsec2_B71\t0\t+" > POT2_topo_region/sec2_B71.bed
# echo -e "MQOP01000008.1\t203887\t860573\tsec1_guy11\t0\t+" > POT2_topo_region/sec1_guy11.bed
# echo -e "MQOP01000016.1\t316973\t356717\tsec2_guy11\t0\t-" > POT2_topo_region/sec2_guy11.bed
# echo -e "UCNY03000007.1\t1454502\t2050941\tsec1_US71\t0\t-" > POT2_topo_region/sec1_US71.bed
# echo -e "UCNY03000016.1\t258867\t298214\tsec2_US71\t0\t+" > POT2_topo_region/sec2_US71.bed
# echo -e "CP050926.1\t642233\t1219575\tsec1_LpKY97\t0\t+" > POT2_topo_region/sec1_LpKY97.bed
# echo -e "CP050926.1\t262822\t302294\tsec2_LpKY97\t0\t+" > POT2_topo_region/sec2_LpKY97.bed
# echo -e "CP034210.1\t721972\t1304115\tsec1_MZ5-1-6\t0\t+" > POT2_topo_region/sec1_MZ5-1-6.bed
# echo -e "CP034210.1\t333469\t372927\tsec2_MZ5-1-6\t0\t+" > POT2_topo_region/sec2_MZ5-1-6.bed
# echo -e "CM015044.1\t653621\t1240425\tsec1_NI907\t0\t+" > POT2_topo_region/sec1_NI907.bed
# echo -e "CM015044.1\t95441\t146289\tsec2_NI907\t0\t-" > POT2_topo_region/sec2_NI907.bed

### get fasta for each section
# > POT2_topo_region/sec1.fasta
# > POT2_topo_region/sec2.fasta
# while read GENOME; do
#     bedtools getfasta -name -s -fi GENOME_TREE/hq_genomes/${GENOME}.fasta -bed POT2_topo_region/sec1_${GENOME}.bed >> POT2_topo_region/sec1.fasta
#     bedtools getfasta -name -s -fi GENOME_TREE/hq_genomes/${GENOME}.fasta -bed POT2_topo_region/sec2_${GENOME}.bed >> POT2_topo_region/sec2.fasta
# done < rep_genomes_list.txt

### align, trim, make tree
cd POT2_topo_region
# mafft --maxiterate 1000 --globalpair --quiet --thread 24 sec1.fasta > sec1.afa
# mafft --maxiterate 1000 --globalpair --quiet --thread 24 sec2.fasta > sec2.afa
#echo "*** starting sec1 alignment..."
#mafft --auto --quiet --thread 24 sec1.fasta > sec1.afa
#echo "*** done, starting sec2 alignment..."
#mafft --auto --quiet --thread 24 sec2.fasta > sec2.afa
echo "*** done, trimming..."
trimal -gappyout -in sec1.afa -out sec1.trim1.afa
trimal -gappyout -in sec2.afa -out sec2.trim1.afa
echo "*** done, making trees..."
cat sec1.trim1.afa | tr \( \{ | tr \) \} > sec1.trim.afa
cat sec2.trim1.afa | tr \( \{ | tr \) \} > sec2.trim.afa
raxmlHPC-PTHREADS-SSE3 -s sec1.trim.afa -n RAxML.sec1 -m GTRGAMMA -T 20 -f a -x 12345 -p 12345 -# 100
raxmlHPC-PTHREADS-SSE3 -s sec2.trim.afa -n RAxML.sec2 -m GTRGAMMA -T 20 -f a -x 12345 -p 12345 -# 100
echo "*** done"

