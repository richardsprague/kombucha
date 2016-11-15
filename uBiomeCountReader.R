# uBiomeCountReader.R
# read from a uBiome count file


# return a numeric representation of factor v
reduce_factor_to_numeric<-function(v){
  as.numeric(sapply(v,function (f) levels(f)[f]))
}
# reads a ubiome matrix created by the uBiome command utility
# $ ubiome -m 2016*gut*.json > rik2016gutThru0711.csv
# returns a dataframe where is column is a genus and each row is a sample
read_ubiome_csv<-function(fname,tax_rank="genus"){
  count_df<-read.csv(fname,header=FALSE)
  dates<-as.Date(sapply(count_df[1,-(1:2)],function(f) levels(f)[f]),format="%m/%d/%y")
  count.atRank<-count_df[count_df[,2]==tax_rank,-2]
  names.atRank<-as.character(count.atRank[,1])
  counts.t<-as.data.frame(t(count.atRank[,-1]))
  names(counts.t)<-names.atRank
  d<-as.data.frame(sapply(counts.t,reduce_factor_to_numeric))
  d$dates<-dates
  d
}

# demo: plot just the Bifido levels in a file
#rikGut.f<-read_ubiome_csv("rik2016ThruOct12.csv")
#with(rikGut.f,plot(dates,Bifidobacterium))


