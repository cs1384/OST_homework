#n
1,/\<table/d
/<\/table>/,$d
/<\/tr>/d
/<tr>/d
/"small-state-header"/d
/^$/d
s/&nbsp/ /
s/<[^>]*>//g
s/^[ \t]*//
s/[ \t]*$//
s/\([0-9]*\)\(%\)/\1/
s/\([.]*\)\(*\)/\1/
s/[;]\{1\}$//
p

