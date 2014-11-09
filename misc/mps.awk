#
# mps.awk,  9 Nov 14
#
# Split json for all MPs into one file per MP

function print_node(node_str, node_group, file_str)
{
print "{"  >> file_str
print " \"name\": \"" node_str "\","  >> file_str
print " \"group\": " node_group  >> file_str
print "},"  >> file_str
}


function print_link(tgt_num, file_str)
{
if (first_link != 0)
   print "," >> file_str
first_link=1
print "{"  >> file_str
print " \"source\": " 0 ","  >> file_str
print " \"target\": " tgt_num ","  >> file_str
print " \"value\": " "1"  >> file_str
print "}"  >> file_str
}


function print_comp_node(comp_num, file_str)
{
if (first_comp != 0)
   print "," >> file_str
first_comp=1

print "{"  >> file_str
print " \"name\": \"" node_name[comp_num] "\","  >> file_str
print " \"group\": " "2"  >> file_str
print "}"  >> file_str
}

function print_all_comp_node(src_num, file_str)
{
# print src_num >> file_str
num_comp+=split(src_tgt[src_num], tgt_list, ",")
for (tn in tgt_list)
   print_comp_node(tgt_list[tn], file_str)
}

function print_MP(MP_str)
{
print "{" > MP_str
print " \"nodes\": [" >> MP_str
print_node(MP_str, 1, MP_str)

num_comp=0
first_comp=0
split(MP_node[MP_str], st_num, ",")
for (cn in st_num)
   print_all_comp_node(st_num[cn], MP_str)

print "]," >> MP_str

print " \"links\": [" >> MP_str
first_link=0
for (cn=1; cn <=num_comp; cn++)
   print_link(cn, MP_str)

print "]" >> MP_str
print "}" >> MP_str

close(MP_str)
}


function add_node(node_str)
{
node_map[node_num]=name_node[node_str]
node_name[node_num]=node_str
}

function add_MP(MP_str)
{
if (MP_node[MP_str] == "")
   MP_node[MP_str]=node_num
else
   MP_node[MP_str]=MP_node[MP_str] "," node_num
add_node(MP_str)
}


function whole_name()
{
w_n=substr($2, 2)
for (n=3; n < NF; n++)
   w_n=w_n " " $n
w_n=w_n " " substr($NF, 1, length($NF)-2)
return w_n
}


BEGIN {
	node_num=-1
	}

$1 ~ /"name":/ {
	node_num++
	first_n=substr($2, 2)
	if (substr($NF, 1, 2) == "MP")
	   last_n=$(NF-1)
	else
	   last_n=substr($NF, 1, length($NF)-2)
	w_n=whole_name()
	getline
	if ($2 == 1)
	   add_MP(first_n "_" last_n)
	else
	   add_node(w_n)	
	
	next
	}

$1 ~ /"source":/ {
	src_num=substr($2, 1, length($2)-1)
	getline
	tgt_num=substr($2, 1, length($2)-1)
	if (src_tgt[src_num] == "")
	   src_tgt[src_num]=tgt_num
	else
	   src_tgt[src_num]=src_tgt[src_num] "," tgt_num
	next
	}

	{
	next
	}

END {
	for (mp in MP_node)
	   print_MP(mp)

	}

