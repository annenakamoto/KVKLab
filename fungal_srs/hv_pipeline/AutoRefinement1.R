require(tidyverse)
require(tidytree)
require(treeio)
require(msa)
require(entropy)

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

MinGapFraction <- 0.9
MinGapBlockWidth <- 3
hvSiteEntCutoff <- 1.5
min_hvSites <- 10
Alph_21 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V","-")
Alph_20 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V")
'%ni%' <- Negate('%in%') 

setwd("~/Dropbox/Soy_Proteomes/")



###################################################################
## First Refinement based on MMSEQ alignments and RAxML trees -----
###################################################################
if(!dir.exists("Refinement1")){dir.create("Refinement1")}

files <- list.files("InitialClades",pattern = "Branch",full.names = T)
files 
###old_files <- files
new_files <- files[which(files %ni% old_files)]
new_files <- files[which(grepl(x = files,"cl-1771280"))]

which(grepl(new_files,pattern = "cl-1027471_300"))
for (name in new_files){

     
        tree <- read.raxml(name)
         

        folder <- str_split(basename(name),pattern = "[.]")[[1]][2]
        
        (table <- as_tibble(tree))
        (table<-mutate(table,Clade = folder, mrca_id =  sapply(table$node, get_mrca_name,tree  = table)))
        (table<-mutate(table,Clade = folder, Assembly =  sapply(table$node, get_eco_name,tree  = table)))
        
            
        ###Get number of unique ecotypes left and right of every node
        ###Get number of duplicated ecotypes left and right of every node 
        x<-table
        alltips<-tree@phylo$tip.label
        CountTable<-vector()
        for (nd in x$node){
          #nd<-434
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
        
        good_nodes <- x %>% filter(N_OverlapEco>20, bootstrap>90)
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

        maa <- readAAMultipleAlignment(paste0("InitialClades/",folder,".filtered.afa"))
        #clade <- "cl-1027471_300"
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
          if(nHVsites > min_hvSites){alignment2Fasta(subsetaa,paste0("Refinement1/",clade,".afa"))
            m <- max(2.2,na.omit(ent[,1])%>%unlist)
            ## Make Plots directory if it is not there already
            plots_dir <- "Refinement1/"
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
old_files <- c(old_files,new_files)


which(new_files == "InitialClades/RAxML_bipartitionsBranchLabels.cl-957702_171.Raxml.out")
new_files <- new_files[593:605]



###################################################################
## Second Refinement based on mafft alignments and RAxML trees -----
###################################################################
getwd()
if(!dir.exists("Refinement2")){dir.create("Refinement2")}

files <- list.files("Refinement1",pattern = "Branch",full.names = T)
files %>% unique()
#old_files <- vector()
new_files <- files[which(files %ni% old_files)]
#new_files <- files[which(grepl(x = files,"cl-1771280"))]

#which(grepl(new_files,pattern = "cl-1027471_300"))

for (name in new_files){
  
  
  tree <- read.raxml(name)
  
  
  folder <- str_split(basename(name),pattern = "[.]")[[1]][2]
  
  (table <- as_tibble(tree))
  (table<-mutate(table,Clade = folder, mrca_id =  sapply(table$node, get_mrca_name,tree  = table)))
  (table<-mutate(table,Clade = folder, Assembly =  sapply(table$node, get_eco_name,tree  = table)))
  
  
  ###Get number of unique ecotypes left and right of every node
  ###Get number of duplicated ecotypes left and right of every node 
  x<-table
  alltips<-tree@phylo$tip.label
  CountTable<-vector()
  for (nd in x$node){
    #nd<-434
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
  
  good_nodes <- x %>% filter(N_OverlapEco>20, bootstrap>90)  ######## KEY PARAMETER
  long_nodes <- x %>% filter(branch.length > 0.3)            ######## KEY PARAMETER
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
  
  maa <- readAAMultipleAlignment(paste0("Refinement1/",folder,".afa"))
  #clade <- "cl-1027471_300"
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
    if(nHVsites > min_hvSites){alignment2Fasta(subsetaa,paste0("Refinement2/",clade,".afa"))
      m <- max(2.2,na.omit(ent[,1])%>%unlist)
      ## Make Plots directory if it is not there already
      plots_dir <- "Refinement2/"
      
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
old_files <- c(old_files,new_files)%>%unique()


###################################################################
## Third Refinement, based on mafft alignments and RAxML trees -----
###################################################################
getwd()
if(!dir.exists("Refinement3")){dir.create("Refinement3")}

files <- list.files("Refinement2",pattern = "Branch",full.names = T)
files %>% unique()
old_files <- vector()
new_files <- files[which(files %ni% old_files)]
#new_files <- files[which(grepl(x = files,"cl-1771280"))]

#which(grepl(new_files,pattern = "cl-1027471_300"))

for (name in new_files){
  
  
  tree <- read.raxml(name)
  
  
  folder <- str_split(basename(name),pattern = "[.]")[[1]][2]
  
  (table <- as_tibble(tree))
  (table<-mutate(table,Clade = folder, mrca_id =  sapply(table$node, get_mrca_name,tree  = table)))
  (table<-mutate(table,Clade = folder, Assembly =  sapply(table$node, get_eco_name,tree  = table)))
  
  
  ###Get number of unique ecotypes left and right of every node
  ###Get number of duplicated ecotypes left and right of every node 
  x<-table
  alltips<-tree@phylo$tip.label
  CountTable<-vector()
  for (nd in x$node){
    #nd<-434
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
  
  good_nodes <- x %>% filter(N_OverlapEco>20, bootstrap>90)  ######## KEY PARAMETER
  long_nodes <- x %>% filter(branch.length > 0.3)            ######## KEY PARAMETER
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
  
  maa <- readAAMultipleAlignment(paste0("Refinement2/",folder,".afa"))
  #clade <- "cl-1027471_300"
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
    if(nHVsites > min_hvSites){alignment2Fasta(subsetaa,paste0("Refinement3/",clade,".afa"))
      m <- max(2.2,na.omit(ent[,1])%>%unlist)
      ## Make Plots directory if it is not there already
      plots_dir <- "Refinement3/"
      
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
old_files <- c(old_files,new_files)%>%unique()
 


###################################################################
## Fourth Refinement, based on mafft alignments and RAxML trees -----
###################################################################
getwd()
setwd("~/Dropbox/Soy_Proteomes/")
if(!dir.exists("Refinement4")){dir.create("Refinement4")}

files <- list.files("Refinement3",pattern = "Branch",full.names = T)
files %>% unique()
old_files <- vector()
new_files <- files[which(files %ni% old_files)]
#new_files <- files[which(grepl(x = files,"cl-1771280"))]

#which(grepl(new_files,pattern = "cl-1027471_300"))

for (name in new_files){
  
  
  tree <- read.raxml(name)
  
  
  folder <- str_split(basename(name),pattern = "[.]")[[1]][2]
  
  (table <- as_tibble(tree))
  (table<-mutate(table,Clade = folder, mrca_id =  sapply(table$node, get_mrca_name,tree  = table)))
  (table<-mutate(table,Clade = folder, Assembly =  sapply(table$node, get_eco_name,tree  = table)))
  
  
  ###Get number of unique ecotypes left and right of every node
  ###Get number of duplicated ecotypes left and right of every node 
  x<-table
  alltips<-tree@phylo$tip.label
  CountTable<-vector()
  for (nd in x$node){
    #nd<-434
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
  
  good_nodes <- x %>% filter(N_OverlapEco>20, bootstrap>90)  ######## KEY PARAMETER
  long_nodes <- x %>% filter(branch.length > 0.3)            ######## KEY PARAMETER
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
  
  maa <- readAAMultipleAlignment(paste0("Refinement3/",folder,".afa"))
  #clade <- "cl-1027471_300"
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
    if(nHVsites > min_hvSites){alignment2Fasta(subsetaa,paste0("Refinement4/",clade,".afa"))
      m <- max(2.2,na.omit(ent[,1])%>%unlist)
      ## Make Plots directory if it is not there already
      plots_dir <- "Refinement4/"
      
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
old_files <- c(old_files,new_files)%>%unique()


###################################################################
## Fifth Refinement, based on mafft alignments and RAxML trees -----
###################################################################
getwd()
setwd("~/Dropbox/Soy_Proteomes/")
if(!dir.exists("Refinement5")){dir.create("Refinement5")}

files <- list.files("Refinement4",pattern = "Branch",full.names = T)
files %>% unique()
old_files <- vector()
new_files <- files[which(files %ni% old_files)]
#new_files <- files[which(grepl(x = files,"cl-1771280"))]

#which(grepl(new_files,pattern = "cl-1027471_300"))

for (name in new_files){
  
  
  tree <- read.raxml(name)
  
  
  folder <- str_split(basename(name),pattern = "[.]")[[1]][2]
  
  (table <- as_tibble(tree))
  (table<-mutate(table,Clade = folder, mrca_id =  sapply(table$node, get_mrca_name,tree  = table)))
  (table<-mutate(table,Clade = folder, Assembly =  sapply(table$node, get_eco_name,tree  = table)))
  
  
  ###Get number of unique ecotypes left and right of every node
  ###Get number of duplicated ecotypes left and right of every node 
  x<-table
  alltips<-tree@phylo$tip.label
  CountTable<-vector()
  for (nd in x$node){
    #nd<-434
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
  
  good_nodes <- x %>% filter(N_OverlapEco>20, bootstrap>90)  ######## KEY PARAMETER
  long_nodes <- x %>% filter(branch.length > 0.3)            ######## KEY PARAMETER
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
  
  maa <- readAAMultipleAlignment(paste0("Refinement4/",folder,".afa"))
  #clade <- "cl-1027471_300"
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
    if(nHVsites > min_hvSites){alignment2Fasta(subsetaa,paste0("Refinement5/",clade,".afa"))
      m <- max(2.2,na.omit(ent[,1])%>%unlist)
      ## Make Plots directory if it is not there already
      plots_dir <- "Refinement5/"
      
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
old_files <- c(old_files,new_files)%>%unique()
