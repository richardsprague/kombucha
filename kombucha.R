# kombucha.R
# analyze my kombucha experiment
# first day drinking kombucha: 7/27 (results are a day later)
# last day of kombucha: Aug 2 (results are a few days later)

require(ggplot2)
source('uBiomeCountReader.R')

rikGut<-read_ubiome_csv("kombucha-gut.csv")
rikGut.family<-read_ubiome_csv("kombucha-gut.csv",tax_rank="family")

#returns the rows between the two dates (inclusive)
date_range<-function(df,from,to){
  df[df$dates>=as.Date(from)&df$dates<=as.Date(to),]
  
}


kombucha<-date_range(rikGut,"2016-07-26","2016-08-05"   )#"2016-07-26","2016-08-03")
kombucha.family<-date_range(rikGut.family,"2016-07-26","2016-08-03")

# handle outliers
kombucha.family<-kombucha.family[-6,] # get rid of the outlier
#which(kombucha$Bifidobacterium>50000)  # this is the outlier sample "taken from the second part"
#kombucha$dates[6]  # second part
kombucha<-kombucha[-6,]  # get rid of outlier
#kombucha<-kombucha[-which(kombucha$Clostridium>9000)]

kombucha$experiment <- "none"  # set all days to drink kombucha
#manually set the days when the sample includes no kombucha
kombucha[kombucha$dates %in% date_range(kombucha,"2016-07-28","2016-08-02")$dates,which(names(kombucha)=="experiment")]<-"kombucha"
#kombucha[kombucha$dates==as.Date("2016-08-03"),]$experiment <- "none"

p<-ggplot(kombucha[kombucha$dates>"2016-07-25",],aes(x=dates))+geom_bar(aes(y=Lactobacillus,fill=experiment),stat="identity")
p + theme(panel.background=element_rect(fill="lightblue")) # + facet_grid(~experiment)

#with(july,qplot(dates,Bifidobacterium,geom="line"))
with(kombucha,qplot(dates,Bifidobacterium,geom="line"))

# plot diversity levels 
require('vegan')
#can't do it with this dataset: must use count not count_norm
# with(kombucha,tapply(count,ssr,function(x) diversity(x,index="simpson")))

sapply(kombucha,sd)
max(kombucha.family[1,-which(colnames(kombucha.family)=="dates")])

