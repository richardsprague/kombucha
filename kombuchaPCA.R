# kombuchaPCA.R
# do simple PCA analysis on my kombucha data set


source("kombucha.R") # loads the data sets, especially the family-level abundance information
setwd("~/dev/selfAnalysis") # set back to the project directory

require(caret)
require(stats)
require(dplyr)
require(tidyr)

# read healthy users  (commented out to save processing time)
#healthy<-read_excel("/Users/sprague/OneDrive/ubiome/data/ubiome corp/healthy/807_healthy_samples_results_taxoncount.xlsx")
#healthy.family<-select(filter(healthy,tax_rank=="family"),ssr,tax_name,count_norm)
healthy.family<-tbl_df(healthy.family)
hf<-healthy.family %>% group_by(ssr) %>% spread(tax_name,count_norm)
hf[is.na(hf)]<-0

kom <- kombucha.family[1:3,-which(names(kombucha.family)=="dates")] # just the taxa values, not the dates

#  tried this transformation but I get errors
# trans = preProcess(kom,method=c("center","scale","pca"))
# PC = predict(trans, kom)
# head(PC,3)

log.kom <- log(kom)
kom.pca <- prcomp(kom)
summary(kom.pca)
plot(kom.pca,type="l")

biplot(kom.pca,kombucha.family$dates)
print(kom.pca)

######
# PCoA
require(ape)

# this function is needed to fix a bug in the base function
# http://stackoverflow.com/questions/37501777/changing-axes-labels-for-biplot-in-r
biplot.pcoa <- function (x, Y = NULL, plot.axes = c(1, 2), dir.axis1 = 1, dir.axis2 = 1, 
                         rn = NULL, ...) 
{
  k <- ncol(x$vectors)
  if (k < 2) 
    stop("There is a single eigenvalue. No plot can be produced.")
  if (k < plot.axes[1]) 
    stop("Axis", plot.axes[1], "does not exist.")
  if (k < plot.axes[2]) 
    stop("Axis", plot.axes[2], "does not exist.")
  if (!is.null(rn)) 
    rownames(x$vectors) <- rn
  args <- list(...)
  labels = ifelse(c("xlab", "ylab") %in% names(args), c(args$xlab, args$ylab), colnames(x$vectors[, plot.axes]))
  diag.dir <- diag(c(dir.axis1, dir.axis2))
  x$vectors[, plot.axes] <- x$vectors[, plot.axes] %*% diag.dir
  if (is.null(Y)) {
    limits <- apply(x$vectors[, plot.axes], 2, range)
    ran.x <- limits[2, 1] - limits[1, 1]
    ran.y <- limits[2, 2] - limits[1, 2]
    xlim <- c((limits[1, 1] - ran.x/10), (limits[2, 1] + 
                                            ran.x/5))
    ylim <- c((limits[1, 2] - ran.y/10), (limits[2, 2] + 
                                            ran.y/10))
    par(mai = c(1, 1, 1, 0.5))
    title <- ifelse("main" %in% names(args), args$main, "PCoA ordination")
    plot(x$vectors[, plot.axes], xlab = labels[1], ylab = labels[2], 
         xlim = xlim, ylim = ylim, asp = 1, 
         main = title)
    text(x$vectors[, plot.axes], labels = rownames(x$vectors), 
         pos = 4, cex = 1, offset = 0.5)
    #title(main = "PCoA ordination", line = 2.5)
  }
  else {
    n <- nrow(Y)
    points.stand <- scale(x$vectors[, plot.axes])
    S <- cov(Y, points.stand)
    U <- S %*% diag((x$values$Eigenvalues[plot.axes]/(n - 
                                                        1))^(-0.5))
    colnames(U) <- colnames(x$vectors[, plot.axes])
    par(mai = c(1, 0.5, 1.4, 0))
    title <- ifelse("main" %in% names(args), args$main, c("PCoA biplot", "Response variables projected", 
                                                          "as in PCA with scaling 1"))
    biplot(x$vectors[, plot.axes], U, xlab = labels[1], ylab = labels[2], main = title)
    # title(main = c("PCoA biplot", "Response variables projected", 
    #                "as in PCA with scaling 1"), line = 4)
  }
  invisible()
}

# plots just the kombucha experiment
b<-biplot(pcoa(vegdist(kom,"bray"),rn=format(kombucha.family[1:3,]$dates, "%b-%d")),
       main="Kombucha Experiment PCoA", xlab="PC1", ylab="PC2")

jpeg("rikAllData.jpeg")
# this plots all my data for the year
biplot(pcoa(vegdist(rikGut.family[-which(names(rikGut.family)=="dates")],"bray"),rn=format(rikGut.family$dates, "%b-%d")),
       main="Richard's Gut PCoA", xlab="PC1", ylab="PC2")
dev.off()

# send the biplots one at a time to a JPEG file
# pcoa function requires at least 3 rows before it can compute the distance metric and pcoa
# so I send the output in groups of 3.
# Is there a way to find just the coordinates that will be plotted so I can plot them myself?
frame_biplot <- function (df){
  for(i in seq(1,nrow(df)-3)){
    #print(paste(i,"thru",i+2,as.Date(df[i,]$dates,origin = "1970-01-01"),"fname=","rikGutAll-",i,sep=""))
    print(df[i:i+2,68])
    rg<-df[i:(i+2),-68]
    pcoa(vegdist(rg,"bray"))
    jpeg(paste("rikGutAll-",i,".jpeg",sep=""))
    biplot(pcoa(vegdist(rg,"bray"),rn=format(df[i:(i+2),]$dates, "%b-%d")))
    dev.off()
    
  }

}
frame_biplot(rikGut.family)
 
biplot(pcoa(vegdist(rikGut.family[-which(names(rikGut.family)=="dates")],"bray"),rn=format(rikGut.family$dates, "%b-%d")),
       main="Richard's Gut PCoA", xlab="PC1", ylab="PC2")

pc<-pcoa(vegdist(rikGut.family[-which(names(rikGut.family)=="dates")],"bray"),rn=format(rikGut.family$dates, "%b-%d"))
rg.xy<-as.data.frame(pc$vectors[,c(1,2)] ) # (x,y) coords for every sample
colnames(rg.xy)<-c("x","y")
rg.xy$dates<-rikGut.family$dates

# now calculate the healthy users
hf.pc<-pcoa(vegdist(hf[,-1],"bray"),rn=NULL) # ,rn=hf$ssr) # to include the label names
hf.xy<-as.data.frame(hf.pc$vectors[,c(1,2)])
colnames(hf.xy)<-c("x","y")


#send the vectors in df one at a time to a jpeg file; leaves the previous points where they were so you can watch through time.
# df.overlay is a set of points you want in the background (e.g. healthy users)
frame_plots <- function (df,df.overlay){

  for(i in seq(1,nrow(df))){
    #print(paste(i,"thru",i+2,as.Date(df[i,]$dates,origin = "1970-01-01"),"fname=","rikGutAll-",i,sep=""))
    dfrg<-df[i,]
    print(paste(i,dfrg$x,dfrg$y))
    #jpeg(paste("rikGutAll-",i,".jpeg",sep=""))
    png(sprintf("rikGutAll-%03d.png",i))
    with(df.overlay,plot(x,y,col=c("springgreen3"),main="Moving Pictures of My uBiome",xlab="PC1",ylab="PC2",xlim=c(-0.4,0.6),ylim=c(-0.7,0.3)))
    with(df[1:i,],points(x,y,pch=17,col=c("red"),type="l"))
    with(dfrg,points(x,y,pch=17,col=c("red")))
    text(dfrg$x,dfrg$y,as.character(dfrg$dates)) # label each point with the date
    legend("bottomright",legend=c("Healthy","Sprague"),fill=c("springgreen3","red"))
    dev.off()

  }
}
frame_plots(rg.xy,hf.xy)

# with(rg.xy,plot(x[1],y[1],main="Sprague Gut PCoA",xlab="PC1",ylab="PC2",xlim=c(-0.4,0.4),ylim=c(-0.3,0.3)))
# with(rg.xy,points(x[2],y[2],col=c("red")))
# 
# with(rg.xy,plot(x,y,xlim=c(-0.4,0.6),ylim=c(-0.7,0.3)))
# 



with(hf.xy,plot(x,y,col=c("springgreen3"),main="Healthy Users"))
with(rg.xy,points(x,y,pch=17,col=c("red"),type="l"))
with(rg.xy,text(x,y,as.character(dates)))
legend("bottomright",legend=c("Healthy Users","Sprague"),fill=c("springgreen3","red"))
