### Run auto-refinement exactly as in Daniil's script

### options passed from command line
library("optparse")
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

### Libraries:
require(tidyverse)
require(tidytree)
require(treeio)
require(msa)
require(entropy)

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

if(!dir.exists(ref_dir)){dir.create(ref_dir)}

files <- list.files(init_dir,pattern = "Branch",full.names = T)
files 
new_files <- files

for (name in new_files){
     
        tree <- read.raxml(name)
         
        folder <- str_split(basename(name),pattern = "[.]")[[1]][3]   # gets the OG/clade name
        
        (table <- as_tibble(tree))
        (table<-mutate(table,Clade = folder, mrca_id =  sapply(table$node, get_mrca_name,tree  = table)))
        (table<-mutate(table,Clade = folder, Assembly =  sapply(table$node, get_eco_name,tree  = table)))
        
            
        ###Get number of unique ecotypes left and right of every node
        ###Get number of duplicated ecotypes left and right of every node 
        x<-table
        alltips<-tree@phylo$tip.label
        CountTable<-vector()
        for (nd in x$node){
          (R_tips <- offspring(x,nd, tiponly=T, self_include=T))
          (L_tips <- x[which(alltips %ni% R_tips$label),])
          nrow(L_tips)
          if (nrow(L_tips) == 0){L_NE <- 0; L_ND <-0}else{
            (L_ecotypes <- L_tips$Assembly)
            L_NE <- length(unique(L_ecotypes))
            L_ND <- length(unique(L_ecotypes[which(duplicated(L_ecotypes))]))
          }
          (R_ecotypes <- R_tips$Assembly)
          R_NE <- length(unique(R_ecotypes))
          R_ND <- length(unique(R_ecotypes[which(duplicated(R_ecotypes))]))
          OE <- length(intersect(R_ecotypes,L_ecotypes))
          vec <- c(nd,R_NE,R_ND,nrow(R_tips),L_NE,L_ND,nrow(L_tips),OE)
          vec
          CountTable <- rbind(CountTable, vec)
        }
        CountTable
        ###Merge with tree data
        colnames(CountTable) <- c("node","R_Eco","R_DuplEco","R_tips","L_Eco","L_DuplEco","L_tips","N_OverlapEco")
        x <- left_join(x,as_tibble(CountTable), by = "node")
        
        good_nodes <- x %>% filter(N_OverlapEco>Eco_cutoff, bootstrap>90)
        long_nodes <- x %>% filter(branch.length > 0.3)
        Cut_Nodes_10 <- rbind(good_nodes,long_nodes) %>% distinct()
        Cut_Nodes_10 <- mutate(Cut_Nodes_10, Split_Node_1 = T)
        BigTable <- left_join(x, Cut_Nodes_10 %>% select(label,node,Clade,Split_Node_1)%>%distinct(), by = c("label","node","Clade"))
        
        Split_1 <-vector(length = nrow(BigTable))
        i<-1
        for (i in 1:nrow(BigTable)){if (!is.na(BigTable[i,]$label)){                    #works
          (Tip <- BigTable[i,])
          (CurClade <- BigTable[i,]$Clade)
          (TreeData <- filter(BigTable,Clade == CurClade))
          (SplitNodes <- filter(TreeData,Split_Node_1))
          if (nrow(SplitNodes)>0){
            (TopClade <- SplitNodes %>% filter(R_tips == max(SplitNodes$R_tips)))
            TopClade <- TopClade[1,]
            if (is.na(Tip$Split_Node_1)){
              if (nrow(dplyr::intersect(ancestor(TreeData,Tip$node),SplitNodes))>0){
                SplitAncestors <- dplyr::intersect(ancestor(TreeData,Tip$node),SplitNodes)
                SmallestAncestor <- SplitAncestors %>% filter(R_tips == min(SplitAncestors$R_tips))
                BestNode <- paste0(CurClade,'_',SmallestAncestor$node,'_R')
              }else{BestNode <- paste0(CurClade,'_',TopClade$node,'_L')}
            }else{BestNode <- paste0(CurClade,'_',Tip$node,'_R')}
          }else{BestNode <- paste0(CurClade)}
          Split_1[[i]] <- BestNode
        }else{Split_1[[i]] <- NA}}
        
        BigTable_1 <- mutate(BigTable, Split_1 = as.factor(Split_1))
        SubClade <- BigTable_1 %>% select(label, Split_1) %>% arrange(Split_1) %>% filter (!is.na(label)) %>% print(n=1000)
        
        (CladeList <- SubClade %>% select(Split_1) %>% group_by(Split_1)%>%count)
        ##read alignement

        maa <- readAAMultipleAlignment(paste0(init_dir, "/",folder,".afa"))
        for (clade in CladeList$Split_1){
          ##get clade subalignment
          subsetaa <- AAMultipleAlignment(unmasked(maa)[which(maa@unmasked@ranges@NAMES%>%str_remove_all(" ") %in% (SubClade %>%filter(Split_1==clade))$label)])
          clade <- paste0(clade,"_",nrow(subsetaa))
          ##compute entropy
          if ("-" %in% rownames(consensusMatrix(subsetaa))){
            autoMasked <- maskGaps(subsetaa, min.fraction = MinGapFraction, min.block.width = MinGapBlockWidth) ##KEY FILTERING PARAMETERS
            MinAli <- as(autoMasked, "AAStringSet")
          }else{MinAli<-as(subsetaa, "AAStringSet")}
          MinAli
          
          ## Calculating Consensus Matrix
          (Tidy_CM<-as_tibble(t(consensusMatrix(MinAli, baseOnly = T))))
          ## Compensating for consensus matrix not keeping full alphabet in output
          for (a in setdiff(Alph_21,colnames(Tidy_CM))){
            vec <- as_tibble(0*(1:nrow(Tidy_CM)))
            colnames(vec) <- paste(a)
            Tidy_CM <- as_tibble(cbind(Tidy_CM,vec))
          } 
          ##Selecting relevant columns
          (Tidy_CM_Gaps <- select(Tidy_CM,all_of(Alph_21)))
          (Tidy_CM_NoGaps <- select(Tidy_CM,all_of(Alph_20)))
          
          ##Entropy Calculation
          ent <- apply(Tidy_CM_Gaps, 1, entropy,unit="log2") %>% as_tibble()
          colnames(ent)<-paste0("Entropy_",clade)
          ent
          
          ##Entropy Calculation Ignoring Gaps
          entNG <- apply(Tidy_CM_NoGaps, 1, entropy,unit="log2") %>% as_tibble()
          colnames(entNG)<-paste0("EntropyNoGaps_",clade)
          entNG
          
          nHVsites <- length(which(entNG > hvSiteEntCutoff))                          ####KEY CUTOFF PARAMETER
          
          ##if entropy is >1.5 for >10 position, print alignment and plot to new folder
          if(nHVsites > min_hvSites){alignment2Fasta(subsetaa,paste0(ref_dir, "/",clade,".afa"))
            m <- max(2.2,na.omit(ent[,1])%>%unlist)
            ## Make Plots directory if it is not there already
            plots_dir <- paste0(ref_dir, "/")
            if (!dir.exists(plots_dir)){dir.create(plots_dir)}
            ## Entropy plotting
              cat(clade)
              cat(" is a candidate highly variable clade\n")
              Ent <- as_tibble(cbind(1:nrow(ent),ent,entNG))
              colnames(Ent)<-c("Position","Entropy", "EntropyNG")
              
              ggplot(Ent, aes(x = Position))+
                geom_line(aes(y = Entropy), color = "blue")+
                ylim(0,m)+
                ggtitle(paste(clade)) +
                xlab("Position") + 
                ylab("Shannon Entropy with Gaps")+
                theme_classic()
              ggsave(paste0(plots_dir,"/",clade,"_Entropy_Masked",".pdf"))
              
              ggplot(Ent, aes(x = Position))+
                geom_line(aes(y = EntropyNG), color = "red")+
                ylim(0,m)+
                ggtitle(paste(clade)) +
                xlab("Position") + 
                ylab("Shannon Entropy")+
                theme_classic()
              ggsave(paste0(plots_dir,"/",clade,"_Entropy_MaskedNG",".pdf"))
            }
            
        }
}
