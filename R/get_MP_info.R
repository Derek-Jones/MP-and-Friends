#
# get_MP_info.R,  9 Nov 14

root_dir="~/MP-and-Friends/"

source (paste0(root_dir, "R/mp-rel.R"))

library("plyr")


data_dir=paste0(root_dir, "data/")

get_MP_info=function(df)
{
MP_name=paste0(df$given.name, " ", df$family.name)

# print(df)
print(MP_name)
# print(df$birth.date)

MP_direct=directorships(MP_name, df$birth.date)
co_dir=co_directors(MP_direct)
a_cd <<- co_dir
cat(toJSON(co_dir), file=paste0(data_dir, "mp_info/", MP_name))

return(NULL)
}


all_mps=read.csv(paste0(data_dir, "mps.csv"), as.is=TRUE)

dummy=sapply(1:nrow(all_mps), function(X) get_MP_info(all_mps[X, ]))


