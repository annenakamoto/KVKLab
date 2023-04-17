require(tidyverse)
require(tidytree)
require(treeio)
require(msa)
require(entropy)

#setwd("/global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/OG_MAFFT")
setwd("/global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder/OG_Alignments")

### Function: determine if an alignment meets hv criteria
###     afa is the alignment file name
assess_alignment <- function(afa) {
  MinGapFraction <- 0.9
  MinGapBlockWidth <- 3
  hvSiteEntCutoff <- 1.5
  min_hvSites <- 10
  Alph_21 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V","-")
  Alph_20 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V")
  
  maa <- readAAMultipleAlignment(afa)
  
  if ("-" %in% rownames(consensusMatrix(maa))) {
    autoMasked <- maskGaps(maa, min.fraction = MinGapFraction, min.block.width = MinGapBlockWidth) ##KEY FILTERING PARAMETERS
    MinAli <- as(autoMasked, "AAStringSet")
  } else { 
    MinAli<-as(maa, "AAStringSet") 
  }
  
  ## Calculating Consensus Matrix
  Tidy_CM<-as_tibble(t(consensusMatrix(MinAli, baseOnly = T)))
  
  ## Compensating for consensus matrix not keeping full alphabet in output
  for (a in setdiff(Alph_21,colnames(Tidy_CM))){
    vec <- as_tibble(0*(1:nrow(Tidy_CM)))
    colnames(vec) <- paste(a)
    Tidy_CM <- as_tibble(cbind(Tidy_CM,vec))
  } 
  
  ##Selecting relevant columns
  Tidy_CM_Gaps <- select(Tidy_CM,all_of(Alph_21))
  Tidy_CM_NoGaps <- select(Tidy_CM,all_of(Alph_20))
  
  ##Entropy Calculation
  ent <- apply(Tidy_CM_Gaps, 1, entropy,unit="log2") %>% as_tibble()
  colnames(ent)<- paste0("Entropy_", afa)
  
  ##Entropy Calculation Ignoring Gaps
  entNG <- apply(Tidy_CM_NoGaps, 1, entropy,unit="log2") %>% as_tibble()
  colnames(entNG)<- paste0("EntropyNoGaps_", afa)
  
  nHVsites <- length(which(entNG > hvSiteEntCutoff))                          ####KEY CUTOFF PARAMETER
  
  ## CHANGED: print the alignment name and the number of hv sites it contains (to make a distribution)
  print(paste0(afa, "\t", nHVsites))
}

### MAIN
for (aln in list.files()) {
    assess_alignment(aln)
}


