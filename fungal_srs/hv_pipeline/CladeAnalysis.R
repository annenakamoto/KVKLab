## ---------------------------
##
## Script name: Soy_Proteome_hvClade_Analysis.R
##
## Purpose of script: Track results of automatic clade refinement from fasta files saved in InitialClades and Refinement_X folders
##
## Author: Daniil Prigozhin
##
## Date Created: 2022-06-27
##
## Copyright (c) Daniil Prigozhin, 2022
## Email: daniilprigozhin@lbl.gov
##
## ---------------------------
##
## Notes: Only highly variable subclades were carried forward at all steps
##   
##
## ---------------------------
## load packages

require(tidyverse)
require(Biostrings)
require(entropy)
## set working directory

setwd("~/Dropbox/Soy_Proteomes/")  
'%ni%' <- Negate('%in%')




dirs <- c("InitialClades","Refinement1","Refinement2","Refinement3","Refinement4")
dirs <- c("Refinement1","Refinement2","Refinement3","Refinement4")
files <- list.files(path = dirs,full.names = T,pattern = "cl-[0-9_LR]+[.]afa$")
Sum_Tab <- vector(mode = "list",length = length(files))

for(ii in seq_along(files)){
  file <- files[[ii]]
  print(file)
  stage <- (file %>% str_split(pattern = "/"))[[1]][1]
  clade <- (file %>% str_split(pattern = "/"))[[1]][2]%>%str_remove("[.].*")
  maa <- readAAMultipleAlignment(file)
  Sum_Tab[[ii]] <- tibble(Gene = maa@unmasked@ranges@NAMES,Stage = stage, Clade = clade)
}
SumT <- bind_rows(Sum_Tab)
SumT <- SumT %>% mutate(Gene = Gene %>% str_remove_all(" "))
  
InitialClades <- SumT %>% filter(Stage == "InitialClades") %>%select(-Stage)%>%transmute(Gene = Gene, Clade_0 = Clade)
Refinement1 <- SumT %>% filter(Stage == "Refinement1") %>%select(-Stage)%>%transmute(Gene = Gene, Clade_1 = Clade)
Refinement2 <- SumT %>% filter(Stage == "Refinement2") %>%select(-Stage)%>%transmute(Gene = Gene, Clade_2 = Clade)
Refinement3 <- SumT %>% filter(Stage == "Refinement3") %>%select(-Stage)%>%transmute(Gene = Gene, Clade_3 = Clade)
Refinement4 <- SumT %>% filter(Stage == "Refinement4") %>%select(-Stage)%>%transmute(Gene = Gene, Clade_4 = Clade)
Common <- left_join(InitialClades,Refinement1)%>%left_join(Refinement2)%>%left_join(Refinement3)%>%left_join(Refinement4)
Common <- left_join(Refinement1,Refinement2)%>%left_join(Refinement3)%>%left_join(Refinement4)

Common %>%filter(grepl(Gene,pattern = "GLYMA_[0-9]+.*")) %>%select(Gene) %>% distinct()

CladeA<-vector()
Refined <- Common%>%filter(!is.na(Clade_1))

for (l in c(1:nrow(Refined))){
  b<-Refined[l,]
  a<-paste(b[2], sep ="")
  if (!is.na(b[3])){a<-paste(b[3], sep ="")}
  if (!is.na(b[4])){a<-paste(b[4], sep ="")}
  if (!is.na(b[5])){a<-paste(b[5], sep ="")}
  #if (!is.na(b[6])){a<-paste(b[6], sep ="")}
  CladeA<-append(CladeA, a, after = length(CladeA))
}
Refined <- Refined %>% mutate(Clade = CladeA)
Refined

get_eco_name <- function(label){
    if(grepl(x=label,pattern = "GWHPA")){eco = label %>%str_remove_all("[0-9]")}else
      if(grepl(x=label,pattern = "ZH13")){eco = "ZH13"}else
        if(grepl(x=label,pattern = "W05")){eco = "W05"}else
          if(grepl(x=label,pattern = "GLYMA")){eco = "Wm82"}else{eco = NA}
    return(eco)
}
Refined <- Refined %>% mutate(Clade_0 = Clade_1%>%str_extract("cl-[0-9]+_[0-9]+"))
Refined <- Refined %>% mutate(Ecotype = sapply(Gene, get_eco_name))
Refined <- Refined %>% mutate(HV = ifelse(grepl("[0-9]+_[0-9]+$",Clade) | !is.na(Clade_4),1,0))
Refined %>% filter(HV==1) %>% select(Clade) %>%distinct() ####### 290 hv clades
#Refined %>% mutate(Clade_0 = Clade_1 %>% str_split_fixed("_",3))
Refined %>% filter(HV==1) %>% select(Clade_0) %>%distinct() ####### 195 original clades satisfy the hv cutoff post refinement

Pointer <- tibble(File = files) %>% mutate(Clade = File %>%str_remove(".*[/]")%>%str_remove(".afa"))
Refined <- left_join(Refined,Pointer, by = "Clade")

Refined %>% filter(HV ==1) %>%group_by(Ecotype) %>% count %>%print(n=1000)
Refined %>% filter(HV ==1) %>%group_by(Ecotype) %>% count %>%ungroup%>%select(n)%>%ungroup%>%unlist%>%median(na.rm = T)
Refined %>% filter(HV ==1) %>%group_by(Ecotype) %>% count %>%ungroup%>%select(n)%>%ungroup%>%unlist%>%mean(na.rm = T)
600/80000
Refined %>% filter(HV ==1) %>%group_by(Ecotype) %>% count %>%ggplot(aes(x=n))+geom_histogram()

Refined %>% filter(HV==1) %>% select(Clade_0) %>%distinct()

Refined %>% filter(HV==1) %>% select(Clade_0,Clade)%>%distinct()%>%group_by(Clade_0)%>% count %>% filter(n>1) ##45 original clades with multiple hv subclades

######################################
### Join the Uniprot to Wm82 table ---

Mapper <- read_delim("~/Dropbox/RLK_RLP/Soy_RLK_RLP/Proteomes/RecipBestHit.tsv",delim = "\t",col_names = F) %>%transmute(Gene = X1, Uniprot = X2)%>%arrange(Gene)
Mapper
Refined <- left_join(Refined,Mapper,by = "Gene") 
HV_Models <- Refined %>% filter(HV ==1,!is.na(Uniprot))

HV_Models %>%select(Uniprot)%>%distinct()%>%nrow ### 470 Uniprot proteins to check.

setwd("~/Dropbox/Soy_Proteomes/")
getwd()

get_ent <- function(ali, refseq){
  gene <- refseq
  CN <- refseq
  maa <- ali
  ### Check that the protein name matches one alignment key ------------------
  lm <- length(grep(pattern = gene, x=rownames(maa)))
  if (lm == 1) {
    cat ("Found Reference Sequence\n")}else 
      if (lm ==0) {
        stop("Protein name not found in alignment", call.=FALSE)}else
          if (lm > 1) {
            stop("More than one protein matched the name provided", call.=FALSE)}else{stop("Error at protein name", call.=FALSE)}
  ## Masking columns by reference gene ----------------
  Alph_21 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V","-")
  Alph_20 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V")
  RefGene <- gene
  RefSeq <- as(maa, "AAStringSet")[grep(pattern = gene, x=rownames(maa))]
  GapMask<- NULL
  for (i in 1:width(RefSeq)){
    c<-as.vector(RefSeq[[1]][i]) %in% c("-")
    GapMask<-append(GapMask,c,length(GapMask))
  }
  colmask(maa) <- IRanges(GapMask)
  #Retrieving the non-masked subset ------------------
  RefAli <- as(maa, "AAStringSet")
  RefLen <- width(RefAli[1])
  ## Calculating Consensus Matrix -------------------
  Tidy_CM<-as_tibble(t(consensusMatrix(RefAli, baseOnly = T)))
  ## Compensating for consensus matrix not keeping full alphabet in output
  for (a in setdiff(Alph_21,colnames(Tidy_CM))){
    vec <- as_tibble(0*(1:nrow(Tidy_CM)))
    colnames(vec) <- paste(a)
    Tidy_CM <- as_tibble(cbind(Tidy_CM,vec))
  } 
  ##Selecting relevant columns
  Tidy_CM_NoGaps <- select(Tidy_CM,all_of(Alph_20))
  ##Entropy Calculation Ignoring Gaps ----------------------
  entNG <- apply(Tidy_CM_NoGaps, 1, entropy,unit="log2") %>% as_tibble()
  colnames(entNG)<-paste0("EntropyNoGaps_",gene)
  return(entNG)
}

print_ent <- function(entNG,file){
  #Output entropy results to file --------------------------
  sink(file = file,append = F)
  cat("attribute: shannonEntropy\n")
  cat("match mode: 1-to-1\n")
  cat("recipient: residues\n")
  for (ii in seq_along(entNG[[1]])){
    cat("\t")
    cat(paste0(":",ii))
    cat("\t")
    cat(sprintf("%.5f", entNG[[1]][ii]))
    cat("\n")
  }
  sink()   
}

pdf_ent <- function(entNG,file,refseq){
  Ent <- as_tibble(cbind(1:nrow(entNG),entNG))
  colnames(Ent)<-c("Position","Entropy")
  ggplot(Ent, aes(x = Position))+
    geom_line(aes(y = Entropy), color = "blue")+
    ylim(0,3)+
    ggtitle(paste(refseq)) +
    xlab("Position") + 
    ylab("Shannon Entropy")+
    theme_classic()
  ggsave(file)
}


if (!dir.exists("AF_hvClades")) {dir.create("AF_hvClades")}
prefix <- "AF_hvClades/"    

Soy_Uniprot <- readAAStringSet("~/Dropbox/RLK_RLP/Soy_RLK_RLP/Proteomes/corr.SoyUniprot.protein.fasta")
clade <- "cl-1114250_463_606_R_241_337_L_211_281_L_207_250_R_114_161_L_108"
for(clade in HV_Models$Clade%>%unique()){
  print(clade)
  if (dir.exists(paste0(prefix,clade))) {next}
  if (!dir.exists(paste0(prefix,clade))) {dir.create(paste0(prefix,clade))}
  clade_dir <- paste0(prefix,clade,"/")  
  Uniprot_list <- HV_Models%>%filter(Clade ==clade) %>%select(Uniprot,File)%>%distinct()
  for (unip in Uniprot_list$Uniprot){
    system(paste0("wget -O ",clade_dir,unip,".pdb https://alphafold.ebi.ac.uk/files/AF-",unip,"-F1-model_v2.pdb"),ignore.stdout = T)
  }
  list.files(clade_dir)
  ### from a Soy Uniprot collection write a fasta file with new sequences
  writeXStringSet(Soy_Uniprot[Uniprot_list$Uniprot],   paste0(clade_dir ,"uniprot.fasta"))
  ### use system command to run mafft -add
  #system(paste0(" /Users/prigozhin/miniconda/envs/snakemake/bin/mafft --add ",clade_dir,"uniprot.fasta ",Uniprot_list$File[[1]]," > ",clade_dir,clade,".uniprot.afa")) ##MacbookAir
  system(paste0(" /usr/local/bin/mafft --add ",clade_dir,"uniprot.fasta ",Uniprot_list$File[[1]]," > ",clade_dir,clade,".uniprot.afa"))  ##iMac
  
  
  maa <- readAAMultipleAlignment(paste0(clade_dir,clade,".uniprot.afa")) ## change to read the modified alignment
  for (unip in Uniprot_list$Uniprot){
    unip
    maa@unmasked@ranges@NAMES
    ent_ng <- get_ent(maa,unip)
    print_ent(ent_ng,paste0(clade_dir,unip,".ChimeraEntropy.txt"))
    pdf_ent(ent_ng,paste0(clade_dir,unip,".Entropy.pdf"),unip)
  }
}

NLR_Common %>%filter(HV ==1, !is.na(Uniprot)) %>% group_by(Clade_0)%>%count 




### 3243 trees in InitialClades out of 47081 alignment files - alignment entropy, a major cutoff
### 804 trees in Refinement1 out of 826 alignment files - check missing - 22 clades with 3 members
### 245 trees in Refinement2 out of 245 alignment files 
### 55 trees in Refinement3 out of 199 alignment files - check missing - 2 clades size 3, 142 clades that did not change from previous step
### 0 trees in Refinement4 out of 51 alignment files
### Expect 142 hv clades at Refinement2, and 

### 3243 potential hv clades after first cut off, 826 potential hv clades after first full length alignment/tree splitting,
### Analysis of 804 trees cuts down number of hv candidate clades to 245 subclade alignments
### All of these give rise to trees, their analysis leads to 199 candidate clades 
### (with 142 invariant since previous step,2 too small, and 55 further refined)  142 FINAL hvCLADES HERE
### 55 trees produced 51 alignments 
### (with 37 invariant since previous step, 0 too small, and 14 that could be further refined) 37 FINAL hvCLADES HERE
### 14 clades that need trees built  - can all included in the final set - 14 FINAL hvCLADES HERE 

getwd()
if (!dir.exists("PFAM_hvClades")) {dir.create("PFAM_hvClades")}
prefix <- "PFAM_hvClades/"
HV_Models %>% select(Uniprot) %>% distinct() %>% nrow 
writeXStringSet(Soy_Uniprot[HV_Models$Uniprot], paste0(prefix,"uniprot.fasta"))
Pfam_table <- read_delim("PFAM_hvClades/Uniprot.PFAM.reduced.out",delim = "\t")
Pfam_table %>% group_by(query_name) %>% count%>%arrange(n) %>% print(n=10000)
HV_Models %>% filter(Uniprot %ni% Pfam_table$target_name) %>%group_by(Clade_0) %>%count ##### 6 initial clades are not hit by PFAM domains

HV_Models %>% filter(Uniprot =="I1NCA5")
Pfam_table %>% filter(target_name =="I1NCA5")

# ###
# 3 cl-2147976_259     2  100 aa peptide with lots of hydrophobic residues that Alphafold does not predict as a compact domain
# 1 cl-133158_87       1  80mer peptide with low entropy scores
# 6 cl-963383_580      2  Small domain that is not hit by Intrepro
#
# 2 cl-1776009_683     2  small folded beta-barrel domain (Nucleic acid-binding, OB-fold) with highly variable tails highest scoring part only present in one Uniprot sequence and looks like a fragment of another unrelated domain
# 4 cl-375200_4224     1  One protein missed somehow, overall a family of UDP-glycosil transferases with roles in small molecule production and detoxification
# 5 cl-403471_93       1  One protein predicted unfolded, one well folded, secreted FAD/NAD(P)-binding domain superfamily

## A few Uniprot hits do not have many variable residues , so the alignment together passes the hv cut off but individual sequences have mostly low entropy. 
## Would like to check each sequence individually before further analysis
hvUniprot <- vector()
hvCutOff <- 1.5
min_hvRes <- 10

for (prot in HV_Models$Uniprot){
      clade <- (HV_Models%>%filter(Uniprot==prot))$Clade[[1]]
      print(clade)
      file <- paste0("AF_hvClades/",clade,"/",clade,".uniprot.afa")
      maa <- readAAMultipleAlignment(file)  
      ent_ng <- get_ent(maa,prot)
      hv <- sum(ent_ng[,1]>hvCutOff)
      if (hv>=min_hvRes){hvUniprot<- c(hvUniprot,prot)}
  }
hvUniprot %>%unique()%>%length() ##384 after filtering
HV_Models %>%select(Uniprot)%>%distinct()%>%nrow ##470 before filtering
HV_Models <- HV_Models %>%filter(Uniprot %in% hvUniprot) 

#HV_Models %>% select(Uniprot) %>%write_tsv("hvUniprot.txt")
#HV_Models %>% select(Clade_0,Uniprot) %>% write_tsv("hvClade_Uniprot.tsv")
HV_Models %>% select(Clade_0)%>%distinct()%>%nrow()
### 79 initial clades with hv proteins

Clade_Pfam <- left_join(HV_Models,Pfam_table %>% transmute(Uniprot = target_name, Pfam = query_name))%>%select(Clade_0,Pfam) %>%distinct()%>%arrange(Clade_0) %>% print(n=1000)
Clade_Pfam %>% select(Clade_0)%>%distinct()%>%nrow
HV_Models %>% select(Clade_0)%>%distinct()%>%nrow
#Clade_Pfam %>%print(n=1000) %>% write_delim("Clade_domain.txt")

NLR_clades <-Clade_Pfam %>% filter(grepl(pattern = "NB-ARC",Pfam)) %>%select(Clade_0)%>%distinct() ##10 NB-ARC clades
Kinase_clades <-Clade_Pfam %>% filter(grepl(pattern = "Pkinase",Pfam)|grepl(pattern = "PK_Tyr",Pfam)) %>%select(Clade_0)%>%distinct() ##15 Kinase clades not all LRR
LRR_clades <- Clade_Pfam %>% filter(grepl(pattern = "LRR",Pfam))%>%select(Clade_0)%>%distinct() ##17 LRR clades
which(NLR_clades$Clade_0 %in% LRR_clades$Clade_0)%>%length() ##9 NLR in LRR
which(Kinase_clades$Clade_0 %in% LRR_clades$Clade_0)%>%length() ##3 Kinase in LRR
which(Kinase_clades$Clade_0 %in% NLR_clades$Clade_0)%>%length() ##0 as expected
#### 5 LRR clades that are not Kinase or NB-ARC, e.i. RLPs

Known_clades <- rbind(NLR_clades,LRR_clades) %>%distinct()
Known_clades ## 18 Known clades

Clade_Pfam %>% filter(Clade_0 %ni% Known_clades$Clade_0) %>% select(Clade_0)%>%distinct()%>%nrow ##61 Clades that are not LRR, including 12 non-LRR Kinases


### Following up clades with many Pfam domain hits
Clade_Pfam %>% filter(Clade_0 %ni% Known_clades$Clade_0) %>% group_by(Clade_0) %>%count %>% arrange(n)%>% print(n=1000)

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1183049_134"))$Uniprot) %>% arrange(target_name,env_from) ## Common domain in cl-1183049_134 is Helitron_like_N, likely Helitron-associated sequences

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-2366937_27"))$Uniprot) %>% arrange(target_name,env_from) %>% print(n=1000)
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-2366937_27"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## Common domains appear Retrotransposon like

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-686416_96"))$Uniprot) %>% arrange(target_name,env_from)
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-686416_96"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## Looks like some SET methyl transferases, highest signal in loops

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-375200_4224"))$Uniprot) %>% arrange(target_name,env_from) ## DUF2484 is common all e-values low
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-375200_4224"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## Well-defined domain, Large cavity with hvResidues at the entrance 
### This is a case of bad Pfam, very good Interpro hit IPR002213, UDP-glucuronosyl/UDP-glucosyltransferase - and a very interesting find! - Would be a nice investigation at protein level

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1669554_5979"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## This is a non-LRR sensor Kinase
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1669554_5979"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## ECD has two similar halves with variable surfaces - pretty awesome!!!
## "Mechanistic insights into the evolution of DUF26-containing proteins in land plants", CYSTEINE-RICH RECEPTOR-LIKE PROTEIN KINASES (CRKs) and PLASMODESMATA-LOCALIZED PROTEINS (PDLPs)

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1663500_59"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## ankyrin repeat proteins that terminates in a transmembrane helix bundle with 4 TM's and a 5th amphiphilic helix
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1663500_59"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## a lot of variable residues in the TM helices! Overall entropy on the lower side.
## Bundle of TMs matches a Major Facilitator Superfamily transporter (IPR036259)!!! 

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1404912_107"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## Very well defined domain composition with 
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1404912_107"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## Thioredoxin_12, Thioredoxin_13, 2x Thioredoxin_14, Thioredoxin_14, UDP-g_GGTase, and Glyco_transf_24
## Entropy scores are not great here (might want to raise the cut off point to screen out this and others that are not too strong)
## UDP-glucose:Glycoprotein Glucosyltransferase (IPR009448), ER quality control protein. Has known roles in immunity: https://www.arabidopsis.org/servlets/TairObject?type=publication&id=501764104

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-960164_228"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## ABC transporter with a highly divergent residues lining the pore - kind of wild
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-960164_228"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ##  

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-93015_1446"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## Another sensor kinase with a variable ECD, no doubt
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-93015_1446"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## The hv residues are not part of the ECD but are part of a stem connecting ECD to membrane
## LEAF RUST 10 DISEASE-RESISTANCE LOCUS RECEPTOR-LIKE PROTEIN KINASE-like (IPR045874). Known disease resistance role!!! 225 hv out of 1446 in the cluster

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1924144_29"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## Helitron collection  
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1924144_29"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## 

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1790735_1480"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## GST with a variable substrate-binding site - clean and beautiful!!!!!
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1790735_1480"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## 

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1776009_683"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## The domains themselves not too variable, attachments are. Expanded DNA repair family
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1776009_683"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## https://www.arabidopsis.org/servlets/TairObject?type=publication&id=501768191
## Rfa1 (also known as RPA70) is a component of the replication protein A (RPA) complex, which binds to and removes secondary structure from ssDNA. The RPA complex is involved in DNA replication, repair, and recombination. (IPR004591)
## Pretty strong signal in some of these that maps to an unstructured tail 

Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1421007_56"))$Uniprot) %>% arrange(target_name,env_from) %>%print(n=1000) ## PPR-Kinase. NO SIGNALP or TMHMM hits! Need to check other sequences. Diversity peaks in the loop between PPR and Kinase
Pfam_table %>% filter(target_name %in% (HV_Models%>%filter(Clade_0 =="cl-1421007_56"))$Uniprot) %>% group_by(query_name)%>%count%>% print(n=1000) ## PPR_prot_plant (IPR045215) have roles in RNA binding
## Why the variable region???


## 10 of 60. Need to take a break and maybe do this more systematically - interpro, SignalP, TMHMM, TAIR.

##########################################
### Correlating to Soy GWAS --------------

read_delim("hvClade_Uniprot.tsv",delim ="\t")
read_delim("hvUniprot.txt",delim = "\t")

Wm82_HV <- Refined %>% filter(Ecotype =="Wm82",HV ==1) 
Wm82_HV <- Wm82_HV %>% mutate(Gene = Gene %>% str_remove("GLYMA_") %>%str_remove("_.*"))

corr_tab <- read_delim("GWAS_Correlates/Wm82.a4.v1_to_Correspondence_Full.csv",delim = ",",col_names = TRUE)%>%filter(Assembly =="Glyma2.0")
corr_tab <- corr_tab %>% mutate(v4_name = `Wm82.a4.v1 Gene`, v2_name = `Corresponding Gene`) %>% 
  mutate(Gene = v4_name %>% str_remove(".*[.]") %>%toupper()) %>%
  mutate(v2_name = v2_name %>% str_remove(".*[.]") %>%toupper()) %>% select(Gene,v2_name)
corr_tab
Wm82_HV <- left_join(Wm82_HV,corr_tab)


gwas <- read_delim("GWAS_Correlates/SoyBase_GWAS_Positions.txt",delim = "\t",col_names = c("Phenotype","Chr","Pos","Assemb"))

gff <-read_delim("GWAS_Correlates/Gmax_275_Wm82.a2.v1.gene_exons.gff3",delim = "\t",comment = "#",col_names = c("chr","source","type","start","end","score","strand","phase","attrib"))

genes <- gff %>% filter(type == "gene")
genes <- genes %>% mutate(v2_name= attrib %>% str_remove("ID=Glyma.")%>%str_remove("[.].*"))%>%select (-Gene)
genes

Wm82_HV <- Wm82_HV %>% left_join(genes) %>% filter(!is.na(chr))
Wm82_HV <- Wm82_HV %>% arrange(chr,start)  
Wm82_HV
gwas <- gwas %>% mutate(chr = Chr%>%str_replace(pattern = "Gm",replacement = "Chr"))%>%select(-Chr)
gwas %>%mutate (Phenotype = Phenotype %>% str_remove("[ ].*"))%>% group_by(Phenotype)%>%count%>%print(n=100)
gwas

link <- vector()
for (ii in 1:nrow(gwas)){
(line <- gwas[ii,])
phen <- line[[1,1]]
chrom <- line[[1,4]]
pos <- line[[1,2]]
table <- Wm82_HV %>%filter(chr == chrom, pos >=(start-50000) & pos<=(end+50000))
if(nrow(table)>0){link<-rbind(link, table%>%select(Gene)%>%mutate(Phenotype = phen))}}
link <- link %>% distinct()
link %>% print(n=200)


##############################################
### Paper Table ------------------------------

HV_Models$Uniprot %>% unique() %>%length()
HV_Models %>% select(Uniprot) %>%distinct() %>% nrow
getwd()
InterPro <- read_delim("hvSoyInterPro/hvUniprot.fasta.gff3",delim = "\t",comment = "#",col_names = c("Uniprot","Source","type","Start","Stop","Score","Strand","Phase","Attr"))
InterPro
InterPro %>% filter(type == "polypeptide")
Len <- InterPro %>% filter(type =="polypeptide") %>% select(Uniprot,Stop)%>%transmute(Uniprot = Uniprot,Len = Stop)
left_join(InterPro,Len)%>%mutate(Fraction = (Stop-Start+1)/Len)%>%filter(type != "polypeptide")%>%
  ggplot(aes(x=Fraction))+geom_histogram()
Inter_Pro <- left_join(InterPro,Len)%>%mutate(Fraction = (Stop-Start+1)/Len)%>%filter(type != "polypeptide")
Inter_Pro <- Inter_Pro %>% group_by(Uniprot) %>% filter(Fraction == max(Fraction, na.rm=TRUE))%>%distinct()
Inter_Pro %>% ggplot(aes(x=Fraction,color = Source))+geom_histogram()
Panther <- Inter_Pro %>%filter(Source == "PANTHER")
Panther %>% ungroup%>%mutate(Panther = Attr%>%str_remove(".*Name=")%>% str_remove("[;:].*"))%>%
  select(Uniprot,Panther)%>%distinct()%>%group_by(Panther)%>%count()%>%arrange(-n)%>%writexl::write_xlsx("Panther_List.xlsx")
Panther%>%select(Attr)
InterPro%>%filter(grepl("PF",Attr))%>%mutate(Desc = Attr%>%str_remove(".*e_desc=")%>%str_remove(";.*"))%>%select(-Attr)%>%
    group_by(Desc)%>%count()%>%arrange(-n) %>% print(n=100)
Inter_Pro%>%writexl::write_xlsx("InterPro_List.xlsx")
InterPro %>% filter(Uniprot =="A0A0R0GIG3")%>%print(n=100)
InterPro %>% select(Uniprot) %>% distinct()
HV_Models
HV_Models %>% arrange(Clade)%>%select(Uniprot,File,Gene,Clade,Clade_0)%>%writexl::write_xlsx("UniProt_List.xlsx")
HV_Models %>%select(Gene)%>%mutate(Gene = Gene %>% str_remove("_[0-9]$") %>%
                                     str_replace("GLYMA_","Glyma."))%>%write_delim("Glyma.hvGene.list.txt")
getwd()


HV_Models
#################################################################
### Find best matching Atha sequence and associated papers ------

UniAtha <- read_delim("hvSoyInterPro/AlnRes.m8",delim = "\t",col_names = c("Uniprot","Atha","Ident","Len","Mism","Gaps","qS","qE","tS","tE","Eval","Score"))
MinUniAtha <- UniAtha %>% group_by(Uniprot) %>% filter(Score == max(Score))%>%ungroup
MinUniAtha <- MinUniAtha %>% mutate(Atha = Atha %>% str_remove("[.].*"))
HV_Models <- HV_Models %>% left_join(MinUniAtha%>%select(Uniprot,Atha))
Atha_links <- HV_Models %>% select(Atha)%>% distinct()
Atha_links
Pub_links <- read_delim("~/Downloads/Locus_Published_20210930.txt",delim = "\t")
Pub_links <- Pub_links %>% filter(grepl("AT[1-5]G",name),!grepl("NULL",pubmed_id))%>%mutate(pubmed_id = as.numeric(pubmed_id))
Small_pids <- Pub_links %>%group_by(pubmed_id)%>%count%>%arrange(-n)%>%filter(n<20)
Pub_links <- Pub_links%>%filter(pubmed_id %in% Small_pids$pubmed_id)

Atha_links %>% left_join(Pub_links, by = c("Atha" = "name"))%>%group_by(Atha) %>%count
x <- "AT1G01010"
gather_pids <- function(x){
  Pub_links %>% filter(name == x) %>% select(pubmed_id) %>% unlist() %>% paste(collapse = ",") %>% return()
}

gather_pids("AT1G01010")

Atha_links%>%mutate(PIDs = sapply(Atha, gather_pids))%>%filter(PIDs != "")

#install.packages("RefManageR")
library("RefManageR")
PaperTibleAll <- vector()
for(i in 0:5){
  PapersBib<-GetPubMedByID((Pub_links %>% filter(name %in% Atha_links$Atha))$pubmed_id[(i*100+1):((i+1)*100)], db = "pubmed")
  PaperTible <- as_tibble(PapersBib)
  PaperTibleAll <- rbind(PaperTibleAll,PaperTible)}
PaperTibleAll

MinPapTibl <- PaperTibleAll%>%transmute(pubmed_id = eprint,title = title,author = author, doi = doi, year = year)

Atha_Paper <- Pub_links %>% mutate(name = name %>%str_remove("[.].*"))%>%filter(name %in% Atha_links$Atha)%>%
  left_join(MinPapTibl%>%mutate(pubmed_id = pubmed_id %>% as.numeric()))
MinUniAtha
Clade_papers <- HV_Models %>% left_join(Atha_Paper %>%mutate(Atha = name) )%>%select(Clade_0,pubmed_id)%>%
  left_join(MinPapTibl%>%mutate(pubmed_id = as.numeric(pubmed_id)))%>%distinct()
Clade_papers %>% writexl::write_xlsx("Clade_papers.xlsx")

x <- "16547105"
gather_gids <- function(x){
  ids <- Pub_links %>% filter(pubmed_id == x) %>% select(name) %>% unlist() %>% paste(collapse = ",") 
  return(ids)
}

gather_gids(x)

Clade_papers <- Clade_papers%>%mutate(GIDs = sapply(pubmed_id, gather_gids))
Clade_papers %>% writexl::write_xlsx("Clade_papers.xlsx")
HV_Models %>% filter(Clade_0 =="cl-1181549_246") %>% select(Gene,Atha)



