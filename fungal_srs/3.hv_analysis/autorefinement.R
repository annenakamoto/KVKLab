### Run auto-refinement exactly as in Daniil's script

### options passed from command line
library("optparse")
library(stringr)
option_list = list(
  make_option(c("-d", "--working_dir"), type="character", default=NULL, 
              help="working directory path [REQUIRED]", metavar="character"),
  make_option(c("-t", "--tree_path"), type="character", default=NULL, 
              help="path from the working dir to the orthogroup tree file [REQUIRED]", metavar="character"),
  make_option(c("-a", "--alignment_path"), type="character", default=NULL, 
              help="path from the working dir to the orthogroup alignment file [REQUIRED]", metavar="character"),
  make_option(c("-e", "--min_eco_overlap"), type="numeric", default=NULL, 
              help="minimun number of overlapping ecotypes [REQUIRED]", metavar="numeric"),
  make_option(c("-u", "--max_branch_length"), type="numeric", default=NULL, 
              help="maximum branch length cutoff [REQUIRED]", metavar="numeric"),
  make_option(c("-l", "--min_branch_length"), type="numeric", default=NULL, 
              help="minimum branch length cutoff [REQUIRED]", metavar="numeric"),
  make_option(c("-b", "--min_bs_support"), type="numeric", default=NULL, 
              help="minimum bootstrap support [REQUIRED]", metavar="numeric"),
  make_option(c("-o", "--out_dir"), type="character", default=NULL, 
              help="path from the working dir to the output dir [REQUIRED]", metavar="numeric")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$working_dir)){
  print_help(opt_parser)
  stop("Working directory is required", call.=FALSE)
}
if (is.null(opt$tree_path)){
  print_help(opt_parser)
  stop("Tree path is required", call.=FALSE)
}
if (is.null(opt$alignment_path)){
  print_help(opt_parser)
  stop("Alignment path is required", call.=FALSE)
}
if (is.null(opt$min_eco_overlap)){
  print_help(opt_parser)
  stop("Minimum ecotype overlap is required", call.=FALSE)
}
if (is.null(opt$max_branch_length)){
  print_help(opt_parser)
  stop("Maximum branch length is required", call.=FALSE)
}
if (is.null(opt$min_branch_length)){
  print_help(opt_parser)
  stop("Minimum branch length is required", call.=FALSE)
}
if (is.null(opt$min_bs_support)){
  print_help(opt_parser)
  stop("Minimum bootstrap support is required", call.=FALSE)
}
if (is.null(opt$out_dir)){
  print_help(opt_parser)
  stop("Output directory is required", call.=FALSE)
}

tree <- opt$tree_path
alignment <- opt$alignment_path
clade <- basename(alignment) %>% str_remove(".afa")
min_eco_overlap <- opt$min_eco_overlap
max_branch_length <- opt$max_branch_length
min_branch_length <- opt$min_branch_length
min_bs_support <- opt$min_bs_support

out_dir <- opt$out_dir
list <- paste0(out_dir, "/", clade, ".subclade_list.txt")
tree_dir <- paste0(out_dir, "/BEAST_TREES")

setwd(opt$working_dir)

### Print run info
cat("*** Running AutoRefinement ***\n")
Sys.time()
cat(paste0("\nWorking directory: ", opt$working_dir, "\n"))
cat(paste0("Tree path: ", opt$tree_path, "\n"))
cat(paste0("Alignment path: ", opt$alignment_path, "\n"))
cat(paste0("Min eco overlap: ", opt$min_eco_overlap, "\n"))
cat(paste0("Max branch length: ", opt$max_branch_length, "\n"))
cat(paste0("Min branch length: ", opt$min_branch_length, "\n"))
cat(paste0("Min bootstrap: ", opt$min_bs_support, "\n"))
cat(paste0("Output directory: ", opt$out_dir, "\n"))

### Libraries:
require(tidyverse)
require(tidytree)
require(treeio)
require(msa)
require(entropy)

### Functions
'%ni%' <- Negate('%in%') 

get_mrca_name <- function(tree,node){
  require(treeio)
  if (!inherits(tree,"tbl_tree")) stop("Agrument must be a 'tbl_tree' object, use as_tibble() on treedata or phylo objects before passing to this function")
  if (isTip(tree,node)){return(NA)}else{
    tip_1 <- offspring(tree,child(tree,node)[1,]$node,tiponly = TRUE, self_include = T)[1,] 
    tip_2 <- offspring(tree,child(tree,node)[2,]$node,tiponly = TRUE, self_include = T)[1,] 
    return(paste0(tip_1$label,"|", tip_2$label))
  }
}

### Daniil's function (edited)
get_eco_name <- function(tree,node){
  require(treeio)
  if (!inherits(tree,"tbl_tree")) stop("Agrument must be a 'tbl_tree' object, use as_tibble() on treedata or phylo objects before passing to this function")
  if (!isTip(tree,node)){return(NA)}else{
    label <- tree[node,]$label
    if (substring(label, 1, 2) == "Zm") {
        eco <- substring(label, 1, 9)   # gets the unique genome identifier, i.e. Zm00021ab
    }
    if (substring(label, 6, 6) == "_") {
        eco <- str_split_1(label, "_")[2]   # gets the unique genome identifier, i.e. D10s71 in MoExx_D10s71_02126 (Works for Mo, Zt, Sc)
    }
    return(eco)
  }
}

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
### end setup


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
save.image(paste0(out_dir, "/", clade, ".SM.RData"))
## Output original tree in the beast format
write.beast(as.treedata(tree_table),file = paste0(out_dir,"/",clade,".beast"))


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
  write.beast(as.treedata(l_o_t[[j]]),file = paste0(out_dir,"/",ref_og,".subtree.beast"))
  
  ## Export clade alignments
  subset <- AAMultipleAlignment(unmasked(maa)[which(maa@unmasked@ranges@NAMES %in% ptree$label)])
  if ("-" %in% rownames(consensusMatrix(subset))){
    autoMasked <- maskGaps(subset, min.fraction = 1, min.block.width = 1) ## remove all-gap columns
    MinAli <- as(autoMasked, "AAStringSet")
  }else{MinAli<-as(subset, "AAStringSet")}
    writeXStringSet(MinAli,filepath = paste0(out_dir,"/",ref_og,".subali.afa"),append = F,format = "fasta")
}

## Export clade stars ----

if (!is_empty(final_nodes)){export <- final_nodes
cladestar <- paste0(out_dir,"/",clade,".cladestar.txt")
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

