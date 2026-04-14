

#### N50 for all the reads
setwd("all_reads/exon1D_read_length_files/")

tsv_files <- list.files(path = ".", pattern = "\\.tsv$", full.names = TRUE)
tsv_files


for (seq_length in tsv_files){
  test<-read.table(seq_length)
  values<-median(test[,3])
  print(paste(test[1,1], values))
}

setwd("all_reads/aorta_heart_read_length_files/")
tsv_files <- list.files(path = ".", pattern = "\\.tsv$", full.names = TRUE)
tsv_files


for (seq_length in tsv_files){
  test<-read.table(seq_length)
  values<-median(test[,3])
  print(paste(test[1,1], values))
}


#### N50 for reads mapping to CACNA1C

setwd("CACNA1C_reads/exon1D_read_length_files/")
tsv_files <- list.files(path = ".", pattern = "\\.tsv$", full.names = TRUE)
tsv_files


for (seq_length in tsv_files){
  test<-read.table(seq_length)
  values<-median(test[,3])
  print(paste(test[1,1], values))
}

setwd("CACNA1C_reads/aorta_heart_read_length_files/")
tsv_files <- list.files(path = ".", pattern = "\\.tsv$", full.names = TRUE)
tsv_files


for (seq_length in tsv_files){
  test<-read.table(seq_length)
  values<-median(test[,3])
  print(paste(test[1,1], values))
}

