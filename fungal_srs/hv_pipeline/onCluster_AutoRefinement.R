### Run auto-refinement exactly as in Daniil's script

### Libraries:
require(tidyverse)
require(tidytree)
require(treeio)
require(msa)
require(entropy)
library("optparse")

### options passed from command line 
option_list = list(
  make_option(c("-wd", "--working_dir"), type="character", default=NULL, 
              help="working directory path, where Refinement and Initial directories are located", metavar="character"),
  make_option(c("-i", "--init_dir"), type="character", default=NULL, 
              help="name of initial directory containing the trees and alignments to refine", metavar="character"),
  make_option(c("-r", "--ref_dir"), type="character", default=NULL, 
              help="name of the directory to output the results of the refinement to", metavar="character"),

  make_option(c("-mgf", "--MinGapFraction"), type="numeric", default=0.9, 
              help="minimum gap fraction of alignment [default=0.9]", metavar="numeric"),
  make_option(c("-mgbw", "--MinGapBlockWidth"), type="numeric", default=3, 
              help="minimum gap block width of alignment [default=3]", metavar="numeric"),
  make_option(c("-hve", "--hvSiteEntCutoff"), type="numeric", default=1.5, 
              help="highly variable site entropy cutoff [default=1.5]", metavar="numeric"),
  make_option(c("-hvs", "--min_hvSites"), type="numeric", default=10, 
              help="minimum number of highly variable sites in alignment [default=10]", metavar="numeric"),
  make_option(c("-eco", "--Eco_cutoff"), type="numeric", default=17, 
              help="number of ecotypes cutoff (this will depend on the number of proteomes used, rule of thumb is 2/3 so 17 for Zm) [default=17]", metavar="numeric"),
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$working_dir)){
  print_help(opt_parser)
  stop("Working directory is required", call.=FALSE)
}
if (is.null(opt$init_dir)){
  print_help(opt_parser)
  stop("Initial directory is required", call.=FALSE)
}
if (is.null(opt$ref_dir)){
  print_help(opt_parser)
  stop("Refinement directory is required", call.=FALSE)
}

MinGapFraction <- opt$MinGapFraction
MinGapBlockWidth <- opt$MinGapBlockWidth
hvSiteEntCutoff <- opt$hvSiteEntCutoff
min_hvSites <- opt$min_hvSites
Eco_cutoff <- opt$Eco_cutoff  # added this, 26*(2/3)=17.3
Alph_21 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V","-")
Alph_20 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V")
'%ni%' <- Negate('%in%') 

setwd(opt$working_dir)
init_dir <- opt$init_dir
ref_dir <- opt$ref_dir

### Print run info
cat("*** Running AutoRefinement ***\n")
Sys.time()
cat(paste0("\nworking directory: ", opt$working_dir, "\n"))
cat(paste0("initial directory: ", opt$init_dir, "\n"))
cat(paste0("refinement directory: ", opt$ref_dir, "\n"))
cat(paste0("MinGapFraction: ", opt$MinGapFraction, "\n"))
cat(paste0("MinGapBlockWidth: ", opt$MinGapBlockWidth, "\n"))
cat(paste0("hvSiteEntCutoff: ", opt$hvSiteEntCutoff, "\n"))
cat(paste0("min_hvSites: ", opt$min_hvSites, "\n"))
cat(paste0("Eco_cutoff: ", opt$Eco_cutoff, "\n"))

### Functions
get_mrca_name <- function(tree,node){
  require(treeio)
  if (!inherits(tree,"tbl_tree")) stop("Agrument must be a 'tbl_tree' object, use as_tibble() on treedata or phylo objects before passing to this function")
  if (isTip(tree,node)){return(NA)}else{
    tip_1 <- offspring(tree,child(tree,node)[1,]$node,tiponly = TRUE, self_include = T)[1,] 
    tip_2 <- offspring(tree,child(tree,node)[2,]$node,tiponly = TRUE, self_include = T)[1,] 
    return(paste0(tip_1$label,"|", tip_2$label))
  }
}

get_eco_name <- function(tree,node){
  require(treeio)
  if (!inherits(tree,"tbl_tree")) stop("Agrument must be a 'tbl_tree' object, use as_tibble() on treedata or phylo objects before passing to this function")
  if (!isTip(tree,node)){return(NA)}else{
    label <- tree[node,]$label
    if(grepl(x=label,pattern = "GWHPA")){eco = label %>%str_remove_all("[0-9]")}else
      if(grepl(x=label,pattern = "ZH13")){eco = "ZH13"}else
        if(grepl(x=label,pattern = "W05")){eco = "W05"}else
          if(grepl(x=label,pattern = "GLYMA")){eco = "Wm82"}else{eco = NA}
    return(eco)
  }
}

alignment2Fasta <- function(alignment, filename) {
  sink(filename)
  
  n <- length(rownames(alignment))
  for(i in seq(1, n)) {
    cat(paste0('>', rownames(alignment)[i]))
    cat('\n')
    the.sequence <- toString(unmasked(alignment)[[i]])
    cat(the.sequence)
    cat('\n')  
  }
  
  sink(NULL)
}
### end setup


### RUN REFINEMENT


