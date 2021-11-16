#!/bin/bash
#SBATCH --job-name=POT2_MUMmer
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=1:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Run MUMmer to find any POT2 + flanking sequences that have synteny
###     Generate fasta of these sequences for guy11, B71, and MZ5-1-6

GENOME=${1}     ### B71 or MZ5-1-6

cd /global/scratch/users/annen

### make chrom length file for slop
#cat JC_cons_genomes/${GENOME}.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/chrom_len.py > POT2_mummer/${GENOME}.len

### make bed file for slop
#cat JC_dist_indiv_TEs/POT2/POT2.${GENOME}.filt_lib.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/make_bed.py > POT2_mummer/${GENOME}.POT2.bed

### Extract the POT2 + flanking sequences
#bedtools slop -i POT2_mummer/${GENOME}.POT2.bed -g POT2_mummer/${GENOME}.len -b 50000 > POT2_mummer/${GENOME}.POT2_flank.bed
#bedtools getfasta -s -name+ -fo POT2_mummer/${GENOME}.POT2_flank.fasta -fi JC_cons_genomes/${GENOME}.fasta -bed POT2_mummer/${GENOME}.POT2_flank.bed


### run MUMmer on each individual fasta pair (all vs all), from ${GENOME}_fastas/ 
cd /global/scratch/users/annen/POT2_mummer/
export GNUPLOT_PS_DIR=/global/scratch/users/annen/MUMmer/gnuplot-5.4.2/share/gnuplot/5.4/PostScript

rm mummerplot_out/*
rm pdf_plots/*
ls guy11_fastas/guy11_POT2* | while read ref; do
    ls ${GENOME}_fastas/${GENOME}_POT2* | while read query; do
        /global/scratch/users/annen/MUMmer/mummer-4.0.0rc1/nucmer -t 24 --maxmatch -p nucmer_out/${query}.${ref} ${ref} ${query}
        /global/scratch/users/annen/MUMmer/mummer-4.0.0rc1/show-coords nucmer_out/${query}.${ref}.delta > show_coords_out/${query}.${ref}.coords
        len=$(cat show_coords_out/${query}.${ref}.coords | awk '/POT2/ { print $7 }')
        pid=$(cat show_coords_out/${query}.${ref}.coords | awk '/POT2/ { print $10 }')
        if [ ${len} -ge 30000 -a  ${pid} -ge 80.0 ]; then
            /global/scratch/users/annen/MUMmer/mummer-4.0.0rc1/mummerplot --postscript --color -p mummerplot_out/${query}.${ref} nucmer_out/${query}.${ref}.delta
            ps2pdf mummerplot_out/${query}.${ref}.ps pdf_plots/${query}.${ref}.pdf
        fi

### Run MUMmer on ALL
#export GNUPLOT_PS_DIR=/global/scratch/users/annen/MUMmer/gnuplot-5.4.2/share/gnuplot/5.4/PostScript
#MUMmer/mummer-4.0.0rc1/nucmer -t 24 --maxmatch -p POT2_mummer/${GENOME}.guy11.POT2.mummer POT2_mummer/guy11.POT2_flank.fasta POT2_mummer/${GENOME}.POT2_flank.fasta
#MUMmer/mummer-4.0.0rc1/mummerplot --postscript --color -p POT2_mummer/mumPLOT.${GENOME}.guy11.POT2 POT2_mummer/${GENOME}.guy11.POT2.mummer.delta
#echo "*** MUMmer plot ***"
#ps2pdf POT2_mummer/mumPLOT.${GENOME}.guy11.POT2.ps POT2_mummer/mumPLOT.${GENOME}.guy11.POT2.pdf
#echo "*** MUMmer plot PDF ***"
#MUMmer/mummer-4.0.0rc1/show-coords POT2_mummer/${GENOME}.guy11.POT2.mummer.delta > POT2_mummer/${GENOME}.guy11.POT2.mummer.coords
#echo "*** MUMmer plot coords ***"

### delta-filter [options] <delta file> > <filtered delta file>
#MUMmer/mummer-4.0.0rc1/delta-filter -r -q -o 100 POT2_mummer/B71.guy11.POT2.mummer.delta > POT2_mummer/B71.guy11.POT2.mummer.filt1.delta
#MUMmer/mummer-4.0.0rc1/mummerplot --postscript --color -p POT2_mummer/mumPLOT.B71.guy11.POT2.filt1 POT2_mummer/B71.guy11.POT2.mummer.filt1.delta
#ps2pdf POT2_mummer/mumPLOT.B71.guy11.POT2.filt1.ps POT2_mummer/mumPLOT.B71.guy11.POT2.filt1.pdf
