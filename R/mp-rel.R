# mp-rel.R, 10 Nov 14
#

library("igraph")
library("RCurl")
library("RJSONIO")

# base_url="https://api.opencorporates.com/companies/gb/"

# Where we get our GB company house data
base_url="https://api.opencorporates.com/v0.4/"

# Format of birth date 1960-12-05
ocomp_date="%Y-%m-%d"

# Need to get one of these from Open Corporates
api_token="5xZxWQiuYXpx76HoAXPL"

# Details about all officers having a given name
get_officer_details=function(name_str, page_num=1)
{
name_url=curlEscape(name_str)
comp_info=getURL(paste0(base_url, "officers/search?q=", name_url,
			"&per_page=100&page=", page_num,
#			"&per_page=3&page=", page_num,
			"&jurisdiction_code=gb&api_token=", api_token))

# https://api.opencorporates.com/v0.4/officers/search?q=diane+abbott&jurisdiction_code=gb

t=fromJSON(comp_info)

return(t)
}

# ac=get_company_details(02152995)
# dj=get_officer_details("diane abbott")

# Return data frame if birth days match
same_birth=function(df, birth_day)
{
# print(df)
# print("same birth")
# print(str(df$officer$date_of_birth))
# print(class(df$officer$date_of_birth))
# print(df$officer$date_of_birth)
# print(unlist(df$officer$date_of_birth))
# print(str(unlist(df$officer$date_of_birth)))
# blah()
if (is.null(df$officer$date_of_birth))
   return(NULL)
if (as.Date(df$officer$date_of_birth, format=ocomp_date) == birth_day)
   {
#   print(df)
   return(df)
   }
return(NULL)
}


# Return list of all people sharing birth day
date_filter=function(direct_list, birth_day)
{
# print(direct_list)
dl=sapply(direct_list$results$officers, function(X) same_birth(X, birth_day))

# Remove NULL elements from list
dl[sapply(dl, is.null)]=NULL

return(dl)
}


process_page=function(name_str, birth_day, page_num=1)
{
off_details=get_officer_details(name_str, page_num)
direct_list=date_filter(off_details, birth_day)

return(direct_list)
}

# Return list of directorships for person having given name and birth day
directorships=function(name_str, birth_day)
{
birth_day=as.Date(birth_day, format=ocomp_date)

# print(birth_day)
off_details=get_officer_details(name_str)
# t_off <<- off_details
direct_list=date_filter(off_details, birth_day)

# return(direct_list)

if (off_details$results$total_pages > 1)
   {
   t=lapply(2:off_details$results$total_pages, function(X) process_page(name_str, birth_day, X))
   t=c(direct_list, t)
   return(unlist(t, recursive=FALSE))
   }
return(direct_list)
}

# Return list of company directors for company_num
company_directors=function(company_num)
{
comp_info=getURL(paste0(base_url, "companies/gb/", company_num, "?api_token=", api_token))

ct=fromJSON(comp_info)

all_officers=ct$results$company$officers
t=lapply(all_officers,
		function(df)
		{
		df$officer$inactive=ct$results$company$inactive
		if (length(ct$results$company$industry_codes) > 0)
		   df$officer$industry_code=as.character(ct$results$company$industry_codes[[1]]$industry_code[3])
		else
		   df$officer$industry_code="NA"
		df$officer$company_link=paste0("https://api.opencorporates.com/companies/gb/", company_num)
		return(df$officer)
		})

return(t)
}


co_directors=function(director_list)
{
co_d=lapply(director_list,
		function(df)
		{
		comp_num=as.character(df$officer$company[[3]])
		t=company_directors(comp_num)
		return(t)
		})

}


# Get Diane Abbott's directorships
# da=directorships("diane abbott", "1953-09-27")
# dc=directorships("david cameron", "1966-10-09")
# then find the co-directors of these companies
# co_da=co_directors(da)


