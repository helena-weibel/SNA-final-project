### PREPARATION

library(rtweet) 
library(tidyverse)
library(igraph)
devtools::install_github("RMHogervorst/gephi")
library(gephi)

### DATA COLLECTION
## Access Twitter API
consumer_key = "" 
consumer_secret = "" 
access_token = "" 
access_secret = ""

## Placeholders
consumer_key = "x" 
consumer_secret = "y" 
access_token = "z" 
access_secret = "a"

token = create_token(
  app = "GA Education SNA", 
  consumer_key = consumer_key,
  consumer_secret = consumer_secret,
  access_token = access_token,
  access_secret = access_secret)
get_token()


## Retrieve last 20 posts from seed list of 37 actors. 
## Types of actors include advocacy, media, state, county, and higher education, and Georgia government.
timelines_23_1 <- get_timelines(c("GaBudget", "FundGAFuture", "georgiadeptofed", "SuptWoods", "BORUSG", "Jumpstart_ATL",
                                  "GaHouseHub", "GASenatePress", "GAPartnership", "GAChamber", "georgiagov",
                                  "Data_Dana", "StephenJOwens_", "SteveDolinger", "GPBEducation", "AJC_Education", "apsupdate", 
                                  "FultonCoSchools", "GwinnettSchools", "Martin4GA", "georgiapolicy", "GovKemp", "GeoffDuncanGA", 
                                  "mdubnik", "wade_state", "JanJonesGA", "RepStephenMeeks", "BradforHD21", "HBWilliamson", 
                                  "SonnyPerdue", "PAGE_EdNews", "jzauner1", "gsbacomm", "gaelassoc", "GAEvoices", "PEM_GA", "SpeakerRalston"
), n = 20)

### DATA EXPLORATION & CLEANING
## Read in R object of the timelines data frame (included in github repository).
timelines_23_1 <- readRDS("timelines_23_1.rds")

## Convert the data frame to a network object with "rtweet"'s "network_graph" function.
## This includes all types of edges: mentions, retweets, replies, and quotes.
## Only mentions were used in the final product, but this was for exploratory purposes, and could be a direction for future research.
net_23_1 <- network_graph(timelines_23_1)
## Simplify the network
net_23_1_simp <- igraph::simplify(net_23_1, remove.loops = T, remove.multiple = T)
## Calculate betweenness centrality.
btwn_23_1_simp <- betweenness(net_23_1_simp, directed=T, weights=NA)

## Plot the network.
plot(net_23_1_simp, 
     edge.arrow.size= 0.2,
     vertex.label.cex = 0.3,
     vertex.size = btwn_23_1_simp*0.05)


## Repeat the process above, but only indcluding mentions as edges.
## This plot is included in the Results section of the paper as Figure 1.
net_23_2 <- network_graph(timelines_23_1, .e = "mention")
net_23_2_simp <- igraph::simplify(net_23_2, remove.loops = T, remove.multiple = T)
btwn_23_2_simp <- betweenness(net_23_2_simp, directed=T, weights=NA)

plot(net_23_2_simp, 
     edge.arrow.size= 0.2,
     vertex.label.cex = 0.3,
     vertex.size = btwn_23_2_simp*0.05)


## Retrieve list of mentions
mentions_23_1 <- timelines_23_1$mentions_screen_name
class(mentions_23_1)
## Convert list to vector
unlist(mentions_23_1)
## Retrieve only values that are not NAs
good_mentions_23_1 <- mentions_23_1[!is.na(mentions_23_1)]
## Remove duplicates
good_mentions_23_2 <- unique(unlist(good_mentions_23_1))


## Using the "rtweet" package again, retrieve the last 20 posts of all  of the 
## accounts mentioned by accounts in the initial list (in their last 20 posts).
## This is done in three steps in order to prevent exceeding the rate limit.
timelines_23_2 <- get_timelines(good_mentions_23_2[1:127], n = 20)
timelines_23_3 <- get_timelines(good_mentions_23_2[128:253], n = 20)
timelines_23_4 <- get_timelines(good_mentions_23_2[254:379], n = 20)

## Combine the original timelines data frame with the three new data frames.
new_df <- rbind(timelines_23_1, timelines_23_2, timelines_23_3, timelines_23_4)
new_df_distinct <- distinct(new_df)

## Read in R object of the combined data frame (included in github repository).
new_df_distinct <- readRDS("new_df_distinct.rds")

## Convert the new data frame to a network object, using only mentions as edges. 
net_24_1 <- network_graph(new_df_distinct, .e = "mention")
## Simplify the network.
net_24_1_simp <- igraph::simplify(net_24_1, remove.loops = T, remove.multiple = T)

## Convert this network object to a format that can be exported to gephi for further exploration and plotting.
gephi_write_edges(net_24_1_simp, "net_24_1_simp_1snowball.csv")
