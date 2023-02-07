library("tidyverse")
require("msa")
require("entropy")

Alph_20 <- c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V")
hvSiteEntCutoff <- 1.5
stats <- vector()
setwd("~/Dropbox/Soy_Proteomes/")

file = ("~/Dropbox/Soy_Proteomes/SoyPanProtDB_c50_m0_MSA.nonull.fasta")

con = file(file, "r")
m<-0
if (file.exists("temp.fa")){file.remove("temp.fa")}
if (file.exists("temp.afa")){file.remove("temp.afa")}
while(TRUE){
  m <- m+1
  line = readLines(con, n = 1) %>%str_remove_all(" ")
  if ( length(line) == 0 ) {
        break
      }
    if(grepl('#',line)){
  ## Stop writing to file  ##     if (sink.number()==1){sink()}
              if (file.exists("temp.fa")){
                    system('grep "\\S" temp.fa > temp.afa')
                    maa <- readAAMultipleAlignment("temp.afa")
                    MinAli<-as(maa, "AAStringSet")
                    
                    ## Calculating Consensus Matrix
                    (Tidy_CM<-as_tibble(t(consensusMatrix(MinAli, baseOnly = T))))
                    
                                ## Compensating for consensus matrix not keeping full alphabet in output
                                for (a in setdiff(Alph_20,colnames(Tidy_CM))){
                                  vec <- as_tibble(0*(1:nrow(Tidy_CM)))
                                  colnames(vec) <- paste(a)
                                  Tidy_CM <- as_tibble(cbind(Tidy_CM,vec))
                                  }
                
                   ##Selecting relevant columns
                   (Tidy_CM_NoGaps <- select(Tidy_CM,all_of(Alph_20)))
                
                    ##Entropy Calculation Ignoring Gaps
                    entNG <- apply(Tidy_CM_NoGaps, 1, entropy,unit="log2") %>% as_tibble()
                    nHVsites <- length(which(entNG > hvSiteEntCutoff))           ####KEY CUTOFF PARAMETER
                    
                    ##Save results
                    stats <- rbind(stats,c(cluster,n_cluster,nHVsites,ncol(maa)))
                    file.remove("temp.fa")
              }
  cluster <- line %>% str_remove('#') %>%str_remove("[|].*")
  n_cluster <- line %>% str_remove(".*n=") %>%str_remove("Desc.*") %>%as.numeric()
    }else if (line ==""){next}else{write_lines(line,"temp.fa",append = TRUE)}
}
close(con)
nrow(stats)
warnings() 

if (file.exists("temp.fa")){file.remove("temp.fa")}
if (file.exists("temp.afa")){file.remove("temp.afa")}

clades <- as_tibble(stats)
colnames(clades) <- c("Clade","Num","nHV","Len")
clades <- clades %>% mutate(Num = as.numeric(Num),nHV = as.numeric(nHV),Len = as.numeric(Len))
clades  %>% 
  mutate(Ratio = nHV/Len)%>%
  ggplot(aes(x = Num,y = nHV))+geom_point()

clades %>% filter(nHV > 5,Num>20) %>% ggplot(aes(x = Len,y = nHV))+geom_point()
clades %>% filter(nHV<5)%>% ggplot(aes(x = Num))+geom_histogram()+xlim(-1,19)

clades %>% filter(nHV >10,Num>3) %>% arrange(Num) %>% select(Clade) %>%write_delim("InitialClades.list",delim = "\t",col_names = T)

write_delim(clades,"SoyPanProtDB_c50_m0_MSA.Clades.tbl",delim = "\t")

initial_clades <- clades %>% filter(nHV >10,Num>3) %>% arrange(Num) %>% select(Clade)


file = ("~/Dropbox/Soy_Proteomes/SoyPanProtDB_c50_m0_MSA.nonull.fasta")
con = file(file, "r")
m <- 0
while(TRUE){
  
  line = readLines(con, n = 1) %>%str_remove_all(" ")
  if ( length(line) == 0 ) {
    break
  }
  if(grepl('#',line)){
    m <- m+1
    print(paste0("Working on clade ",m))
    cluster <- line %>% str_remove('#') %>%str_remove("[|].*")
    n_cluster <- line %>% str_remove(".*n=") %>%str_remove("Desc.*") %>%as.numeric()
    current_file = paste0("InitialClades/",cluster,"_",n_cluster,".afa")
    if (cluster %in% initial_clades$Clade){p=1}else{p=0}
  }else if (line ==""){next}else{write_lines(line,current_file,append = TRUE)}
}

close(con)

getwd()

clades %>% ggplot(aes(x=Num))+geom_histogram()+ylim(-1,50000)
clades %>% arrange(Num) %>% filter(Num<20)%>%select(Num)%>%sum
clades %>% arrange(Num) %>% filter(Num<10)%>%select(Num)%>%sum
clades %>%select(Num)%>%sum

107839/2368548 ##4.5% of all sequences in groups <20 proteins
61206/2368548  ##2.5% of all sequences in groups <10 proteins


clades %>% mutate(CladeNum = paste0(Clade,"_",Num))
clades %>% mutate(CladeNum = paste0(Clade,"_",Num)) %>% filter(nHV >10,Num>3) %>% arrange(Num) %>% select(CladeNum) %>%
  write_delim("InitialClades.list",delim = "\t",col_names = T)

