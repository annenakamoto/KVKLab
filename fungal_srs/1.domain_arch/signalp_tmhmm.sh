#!/bin/bash
#SBATCH --job-name=clade_tree
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Run the SignalP -> TMHMM pipeline to call putative surface receptors



