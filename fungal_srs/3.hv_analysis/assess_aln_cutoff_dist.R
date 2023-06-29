### options passed from command line
library("optparse")
library(stringr)
option_list = list(
  make_option(c("-d", "--working_dir"), type="character", default=NULL, 
              help="the directory containing alignments for hvsite assessment", metavar="character"),
  make_option(c("-f", "--MinGapFraction"), type="numeric", default=0.9, 
              help="minimum gap fraction of alignment [default=0.9]", metavar="numeric"),
  make_option(c("-w", "--MinGapBlockWidth"), type="numeric", default=3, 
              help="minimum gap block width of alignment [default=3]", metavar="numeric")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$working_dir)){
  print_help(opt_parser)
  stop("Working directory is required", call.=FALSE)
}

setwd(opt$working_dir)

cat("*** Running hvsite assessment ***\n")
Sys.time()
cat(paste0("\nworking directory: ", opt$working_dir, "\n"))

## packages
require(tidyverse)
require(tidytree)
require(treeio)
require(msa)
require(entropy)


### Function: determine if an alignment meets hv criteria
###     afa is the alignment file name
assess_alignment <- function(afa, mgf, mgbw) {
  MinGapFraction <- mgf       ## standard is: 0.9
  MinGapBlockWidth <- mgbw    ## standard is: 3
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
  nsites <- length(which(entNG >= 0)) 
  HVsites_norm <- nHVsites / nsites
  print(paste(afa, nHVsites, HVsites_norm, collapse='\t'))
}

### MAIN
for (aln in list.files()) {
    assess_alignment(aln, opt$MinGapFraction, opt$MinGapBlockWidth)
}


