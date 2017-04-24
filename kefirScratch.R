# kefirScratch.R
# okay to delete everything here

DATA_DIR <- paste0(Sys.getenv("UBIOME_DATADIR"),"/ubiome_people/ub_data-Richard_Sprague")
library(actino)
library(ggplot2)


f <- just_json_files_in(DATA_DIR)  # this variable holds the path to all my JSON files. 
m <- paste0(DATA_DIR,'/Richard_Sprague_Mapfile.xlsx')

sprague.all <- join_all_ubiome_files_full(f) # all gut files, unnormalized count 
sprague.all[is.na(sprague.all)] <- 0
gut.all <- sprague.all

sprague.ps.genus <- phyloseq_from_JSON_at_rank(f,m)
colnames(tax_table(sprague.ps.genus))
sprague.ps.order <- phyloseq_from_JSON_at_rank(f,m,"order")
sample_data(sprague.ps.order)$Date <- as.Date(sample_data(sprague.ps.order)$Date, origin = "1899-12-30")
sample_data(sprague.ps.genus)$Date <- as.Date(sample_data(sprague.ps.genus)$Date, origin = "1899-12-30")

colnames(tax_table(sprague.ps.genus)) <- "Genus"

plot(sample_data(sprague.ps.order)$Date, otu_table(sprague.ps.order)["Lactobacillales"])

plot_bar(subset_taxa(subset_samples(sprague.ps.order, Date >= "2017-01-19"), Rank1=="Lactobacillales"),
         x="Date",
         fill = "Rank1")

#save(sprague.all,sprague.ps.genus,sprague.ps.order,file = paste0(DATA_DIR,"/derived/spragueGutThruFeb8.RData"))
# save time by loading a pre-computed version
#load(paste0(DATA_DIR,"/derived/spragueGut.RData"))

plot_bar(sprague.ps.order, fill = "order")

ssrs<-sapply(strsplit(names(sprague.all)[c(-1)],"\\$"),function(x) as.numeric(x[2]))
names(sprague.all)[-1] <- ssrs



gut.genus <- matrix_at_rank(sprague.all)
colnames(gut.genus) <- ssrs
gut.family <- matrix_at_rank(sprague.all, rank = "family")

# show a vector of the number of reads per sample
reads <- as.numeric(sprague.all[1,-1])
dates<-as.Date(sample_data(sprague.ps.genus)$Date, origin = "1899-12-30")
plot(dates[dates>"2016-10-15"],reads[dates>"2016-10-15"])
hist(reads)

# the kefir samples

targetTaxa <- c("Bifidobacterium","Lactobacillus")
kefir.genus <- subset_samples(sprague.ps.genus, Site == "gut" & grepl("[K|k]efir",Label))

sprague.ps.2017 <- subset_samples(sprague.ps.genus, Site == "gut" & Date > "2017-01-01")
sample_data(sprague.ps.2017)$Experiment <- "None"

k <- which(sample_data(sprague.ps.2017)$SSR %in% sample_data(kefir.genus)$SSR)

sample_data(sprague.ps.2017)$Experiment[k] <- "Kefir"


plot_bar(subset_taxa(sprague.ps.2017, Genus %in% targetTaxa),
         fill="Genus", 
         x="Date")

sprague.ps.2017.rare <-rarefy_even_depth(sprague.ps.2017)
plot_bar(subset_taxa(sprague.ps.2017.rare, Genus %in% targetTaxa),
         fill="Genus", 
         x="Date",
         title = "Rarefied")

kefir.ord <- ordinate(sprague.ps.2017.rare, "NMDS")
plot_ordination(sprague.ps.2017.rare,kefir.ord,
                color = "Experiment",
                label = "Date") +
  geom_point(size = 5) +
    ggtitle("NMDS Ordination (Bray-Curtis) after Rarefaction")


biplot <- plot_ordination(sprague.ps.2017.rare,kefir.ord,
                color = "Experiment",
                type = "split",
                label = "Date") +
  geom_point(size = 5) +
  ggtitle("NMDS Ordination (Bray-Curtis) after Rarefaction")


sprague.ps.genus.norm <- transform_sample_counts(sprague.ps.genus, function (x) x / sum(x))
sprague.ps.genus.norm.ord <- ordinate(sprague.ps.genus.norm, "NMDS")
plot_ordination(sprague.ps.genus.norm, sprague.ps.genus.norm.ord,
                color = "Site", label = "Date") +
  geom_point(size = 5) +
  ggtitle("All Sprague Samples: NMDS Ordination (Bray-Curtis)")

