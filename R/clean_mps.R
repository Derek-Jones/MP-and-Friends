# Data scraping for http://lda.data.parliament.uk/
# Accountability Hackathon 8th November 2014

source("mp-rel.R")

library(RCurl)
library(dplyr)

# All MPs listed in the database
mps <- read.csv("commonsmembers.csv", stringsAsFactors = FALSE)
mps <- mps$uri
mps <- strsplit(mps, "/")
mps <- sapply(mps, "[[", 5)

# MPs at time of voting on coalition against ISIL on 2014-09-26 
mps2014 <- read.csv("commonsdivisions_26_09_2014.csv", stringsAsFactors = FALSE)
mps2014 <- mps2014$vote...member...uri
mps2014 <- strsplit(mps2014, "/")
mps2014 <- sapply(mps2014, "[[", 5)

# Retrieve MPs biographies
get_biographies <- function(mps) {
  mps.metadata <- data.frame()
  for (id in mps) {
    uri <- paste0("http://lda.data.parliament.uk/members/", id, ".csv")
    if (url.exists(uri)) {
      profile <- getURI(uri)
      profile <- read.csv(text = profile, stringsAsFactors = FALSE)
      if ("death.date" %in% colnames(profile)) {
        next
      }
      else {
        if (!("additional.name" %in% colnames(profile))) {
          additional.name <- NA
        }
        else {
          additional.name <- unlist(profile[1,"additional.name"])
        }
        mps.metadata <- rbind(mps.metadata, c(id, uri, additional.name, unlist(profile[1,c("given.name", "family.name", "full.name", "birth.date", "gender", "constituency", "party")])))
        mps.metadata <- data.frame(lapply(mps.metadata, as.character), stringsAsFactors=FALSE)
      }
    }
  }
  colnames(mps.metadata) <- c("id", "uri", "additional.name", "given.name", "family.name", "full.name", "birth.date", "gender", "constituency", "party")
  return(mps.metadata)
}

mps.metadata <- get_biographies(mps2014)

# save(mps.metadata, file = "mps.RData")
# write.csv(mps.metadata, file = "mps.csv", row.names = FALSE)
# load("mps.RData")

directors <- NA
for (i in 1:nrow(mps.metadata)) {
  directors <- c(directors, directorships(tolower(paste(mps.metadata[i, c("given.name", "family.name")], collapse = " ")), mps.metadata[i, c("birth.date")]))
}

# save(directors, file = "directors.RData")

directors.df <- data.frame(matrix(unlist(directors), nrow = length(directors), byrow = T))

# save(directors.df, file = "mp_directors.RData")
# write.csv(directors.df, file = "mp_directors.csv", row.names = FALSE)
mp.directors <- read.csv("mp_directors.csv")

# MPs - directors data massaging for graph JSON

unique.companies <- mp.directors %>%
  group_by(company) %>%
  select(name) %>%
  distinct(company, name)
unique.companies$company_id <- seq(nrow(unique.companies)) + 418

unique.mps <- mp.directors %>%
  group_by(name) %>%
  select(name) %>%
  distinct(name)
unique.mps$id <- seq(nrow(unique.mps)) - 1

graph.df <- inner_join(unique.mps, unique.companies, by = "name")
graph.df <- data.frame(graph.df)

# Write json for C3.js

graph.json <- toJSON(list(nodes = c(lapply(which(!duplicated(graph.df$id)), function(x) {list(name = graph.df[,1][x], group = 1)}),
                      lapply(which(!duplicated(graph.df$company_id)), function(x) {list(name = graph.df[,3][x], group = 2)})),
                          links = lapply(seq(nrow(graph.df)), function(x) {list(source = graph.df[,2][x], target = graph.df[,4][x], value = 1)})))
write(graph.json, file ="mps.json")