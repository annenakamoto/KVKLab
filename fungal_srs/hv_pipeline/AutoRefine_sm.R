## ---------------------------
##
## Script name: AutoRefine_sm.R
##
## Purpose of script: Refine clades by splitting clade trees on long branches and well supported branches with 
## large ecotype overlap
##
## Author: Daniil Prigozhin
##
## Date Created: 2023-05-01
##
## Copyright (c) Daniil Prigozhin, 2023
## Email: daniilprigozhin@lbl.gov
##
## ---------------------------
##
## Notes: This is meant to be called by Snakemake with parameters.
##
## ---------------------------
##Installing Packages for alignment manipulation-----------
# install.packages("tidyverse")
# if (!requireNamespace("BiocManager"))
#   install.packages("BiocManager")
# BiocManager::install("msa")
# BiocManager::install("ggtree")
#Loading libraries-----------------------------------------
require(tidyverse)
require(msa)
require(treeio)
require(tidytree)

###########################
## Snakemake parameters ---
###########################
#setwd("~/Dropbox/NLRomes/Citrus_NLRome/RAxML_tree_pbNB-ARC/Initial_Clades/")
# min_eco_overlap <- 10
# max_branch_length <- 0.5
# min_branch_length <- 0.05
# min_bs_support <- 90
# 
# clade <- "Int11590_447"
# 
# tree <- paste0("RAxML_bipartitionsBranchLabels.",clade,".Raxml.out")
# list <- paste0("OG_R1/",clade,".refined.list")
# alignment <- paste0("OGs/",clade,".afa")
# directory <- dirname(alignment)

Samples <- read_delim("Samples.tsv",delim = "\t")%>%mutate(sample = sample %>%toupper()%>%str_replace_all("[.]","_"))

tree <- snakemake@input[["tree"]]
alignment <- snakemake@input[["afa"]]

min_eco_overlap <- snakemake@params[["min_eco_overlap"]]
max_branch_length <- snakemake@params[["max_branch_length"]]
min_branch_length <- snakemake@params[["min_branch_length"]]
min_bs_support <- snakemake@params[["min_bs_support"]]

list <- snakemake@output[["list"]]
old_directory <- dirname(tree)
directory <- dirname(list)
clade <- basename(alignment) %>% str_remove(".afa")

################
## Functions ---
################
## Favorite function of all time
'%ni%' <- Negate('%in%')

## each internal node gets a persistent name based on two leafs
get_mrca_name <- function(tree,node){
  require(treeio)
  if (!inherits(tree,"tbl_tree")) stop("Agrument must be a 'tbl_tree' object, use as_tibble() on treedata or phylo objects before passing to this function")
  if (isTip(tree,node)){return(NA)}else{
    tip_1 <- offspring(tree,child(tree,node)[1,]$node,tiponly = TRUE, self_include = T)[1,] 
    tip_2 <- offspring(tree,child(tree,node)[2,]$node,tiponly = TRUE, self_include = T)[1,] 
    return(paste0(tip_1$label,"|", tip_2$label))
  }
}
## derive ecotype names from leaf names

get_eco_name <- function(tree,node){
  require(treeio)
  if (!inherits(tree,"tbl_tree")) stop("Agrument must be a 'tbl_tree' object, use as_tibble() on treedata or phylo objects before passing to this function")
  if (!isTip(tree,node)){return(NA)}else{
    label <- tree[node,]$label
    eco <- label %>% str_extract(".*_") %>%str_remove("_$")
    if (eco %in% Samples$sample){
    return(eco)
    }else(stop(paste0("Cannot parse ecotype. Check get_eco_name function. ", eco)))
  }
}
#?stop
## Calculate ecotype overlaps for all nodes - how many of source genomes are represented on both sides
## This function is rerun after every split to update the ecotype overlap values
get_eco_overlap <- function(tree,node){
  '%ni%' <- Negate('%in%')
  require(treeio)
  if (!inherits(tree,"tbl_tree")) stop("Agrument must be a 'tbl_tree' object, use as_tibble() on treedata or phylo objects before passing to this function")
    offsp <- offspring(tree,node,tiponly = TRUE,self_include = TRUE)
    compl_tips <- tree %>% filter(!is.na(label),label %ni% offsp$label)
    overlap <- filter(offsp, Assembly %in% compl_tips$Assembly) 
    return(nrow(overlap %>% select(Assembly) %>%distinct()))
}

## KEY PARAMETERS ARE APPLIED inside this function
## operates on lists of trees, produces lists of nodes to cut
## selects nodes to cut based on combination of br length, ecotype overlap and bs support
## arranges output first by ecotype overlap, than by br length
get_cut_nodes <- function(x){
  cut_nodes <- list()
  ## Need to check that a tree is non-trivial
  for (i in seq_along(x)){
    tr_table <- x[[i]]
    if(nrow(tr_table)>2){
    tr_table <- mutate(tr_table, Eco_overlap =  sapply(tr_table$node, get_eco_overlap,tree  = tr_table))
    cut_nodes[[i]] <- tr_table %>% 
      filter(branch.length >max_branch_length | (bootstrap >min_bs_support & Eco_overlap > min_eco_overlap & branch.length > min_branch_length)) %>% arrange(-Eco_overlap,-branch.length)
    }
    else{cut_nodes[[i]]<- tibble()}
  }
  return(cut_nodes)
}

####################
## tree splitter ---
####################
## Read tree, convert to table
tree <- read.raxml(tree)
tree_table <- as_tibble(tree)          
#ggtree(tree)+theme_tree2()+xlim(0,1)

## Add missing data columns using functions above
tree_table<-mutate(tree_table, mrca_id =  sapply(tree_table$node, get_mrca_name,tree  = tree_table),
                                Assembly =  sapply(tree_table$node, get_eco_name,tree  = tree_table),)

tree_table<-mutate(tree_table, Eco_overlap =  sapply(tree_table$node, get_eco_overlap,tree  = tree_table))

## Initialize list of trees, collection of final cut nodes and current cut node candidates
l_o_t <- list(tree_table) 
final_nodes <- vector()
cut_nodes <- get_cut_nodes(l_o_t)

## Split the tree by updating list of trees in place
while (max(sapply(cut_nodes,nrow)) >0){                 ## refinement converges when cut node candidates are exhausted
  print(paste0("Refining ",clade," with ", length(l_o_t)," tree(s)"))
  
  for( i in seq_along(l_o_t)){
    if(nrow(cut_nodes[[i]])==0){next}              ## skip trees that cannot be further refined
    else{
      (tree0 <- l_o_t[[i]])
      (nodes <- cut_nodes[[i]])
      final_nodes <- rbind(final_nodes,nodes[1,])    ## save node that we split on in the 'final' collection
      (top_node <- nodes[[1,2]])                     ## because the list is ordered, take first element

      (offsp <- offspring(tree0,top_node,tiponly = TRUE,self_include = TRUE))      ## offspring tips
      (compl_tips <- tree0 %>% filter(!is.na(label),label %ni% offsp$label))       ## all other tips
      
      (tree1 <- treeio::drop.tip(as.treedata(tree0),compl_tips$label) %>% as_tibble())      ## first half-tree

      (tree2 <- treeio::drop.tip(as.treedata(tree0),offsp$label)%>% as_tibble())            ## second half-tree
      
      l_o_t[[i]] <- tree1                                                                   ## replace original
      l_o_t[[(length(l_o_t)+1)]] <- tree2                                                   ## add second tree to the end
      (cut_nodes <- get_cut_nodes(l_o_t))                                                   ## update cut node candidates
    }
  }
}
print(paste0(clade, " produced ", length(l_o_t)," refined sub-tree(s) split on following nodes"))
print(final_nodes)
#l_o_t
#cut_nodes
#####################
## Output Results ---
#####################
save.image("SM.RData")
## Output original tree in the beast format
write.beast(as.treedata(tree_table),file = paste0(old_directory,"/",clade,".beast"))


##Export sub-clade lists and trees; read, subset, gap mask, and export alignments ----

maa <- readAAMultipleAlignment(alignment)
maa@unmasked@ranges@NAMES <- maa@unmasked@ranges@NAMES %>% str_remove_all(" ")
j <- 1
for (j in seq_along(l_o_t)){
  ptree <- l_o_t[[j]]%>% select(label) %>% filter(!is.na(label))
  ref_og <- paste0(clade,"_",j,"_",nrow(ptree))
  to_print  <- ptree %>% select(label) %>% filter(!is.na(label))%>% transmute(Gene = label, OG = clade, Refined_OG = ref_og)
  
  ## Print clade lists
  write_delim(to_print, file = list, col_names = TRUE, append = TRUE)
  
  ## Export clade tree
  write.beast(as.treedata(l_o_t[[j]]),file = paste0(directory,"/",ref_og,".subtree.beast"))
  
  ## Export clade alignments
  subset <- AAMultipleAlignment(unmasked(maa)[which(maa@unmasked@ranges@NAMES %in% ptree$label)])
  if ("-" %in% rownames(consensusMatrix(subset))){
    autoMasked <- maskGaps(subset, min.fraction = 1, min.block.width = 1) ## remove all-gap columns
    MinAli <- as(autoMasked, "AAStringSet")
  }else{MinAli<-as(subset, "AAStringSet")}
    writeXStringSet(MinAli,filepath = paste0(directory,"/",ref_og,".subali.afa"),append = F,format = "fasta")
}

## Export clade stars ----

if (!is_empty(final_nodes)){export <- final_nodes
cladestar <- paste0(directory,"/",clade,".cladestar.txt")
sink(cladestar, append = F)
cat("DATASET_SYMBOL
SEPARATOR SPACE

#label is used in the legend table (can be changed later)
DATASET_LABEL CutNodes")
#cat(paste0("_",min_seq,"_",max_seq,"\n"))
cat("

#dataset color (can be changed later)
COLOR #ffff00
MAXIMUM_SIZE 10
BORDER_WIDTH 2
BORDER_COLOR #000000
DATA
")
for (ii in 1:length(export$label)){
  if(!is.na(export[ii,6])){
    cat(export[ii,6] %>% unlist())}else{cat(export[ii,4] %>% unlist())}
  if (export[ii,3]>0.3){cat(" 3 10 #00FF00 1 0.25\n")}else
    if (export[ii,3]>0.1){cat(" 3 10 #FFFF00 1 0.25\n")}else
    {cat(" 3 10 #ff0000 1 0.25\n")}
}
sink()
}

