#!/bin/bash

function assureDirExists {
	if [[ ! -d $1 ]]; then
		mkdir -p $1
		chmod 755 $1
		return 0
	else
		return 1
	fi
}

if [[ $# < 1 ]]; then
	echo "No option is given" > /dev/stderr
	exit 1
fi

if [[ $1 == create ]]; then
	if [ $# -gt 3 ] || [ $# -lt 2 ]; then
		echo "The wrong number of arguments are given to an option (too few 
			or too many)" > /dev/stderr
		exit 1
	fi
	if [[ $2 = */* ]]; then
		echo "Invalid arguments" > /dev/stderr
		exit 1
	fi
	if [[ -f $HOME/.question/questions/$2 ]]; then
		echo "The question id exists already" > /dev/stderr
		exit 1
	fi
	if [[ $# > 2 ]]; then
		content=$(echo $3)
	else
		read content
	fi
	if [[ $content = *====* ]]; then
		echo "not added! question contains \"====\"" > /dev/stderr
		exit 1
	fi
	if [[ $content = "" ]]; then
		echo "not added! empty question" > /dev/stderr
		exit 1
	fi
	assureDirExists "$HOME/.question/questions"
	touch "$HOME/.question/questions/$2"
	chmod 705 "$HOME/.question/questions/$2"
	echo $content >> "$HOME/.question/questions/$2"
	exit 0
fi

if [[ $1 == answer ]]; then
	if [ $# -gt 4 ] || [ $# -lt 3 ]; then
		echo "The wrong number of arguments are given to an option (too few 
			or too many)" > /dev/stderr
		exit 1
	fi
	if [[ ! $2 = */* ]]; then
		echo "Invalid arguments" > /dev/stderr
		exit 1
	fi
	user=$(echo $2 | cut -d/ -f1)
	qname=$(echo $2 | cut -d/ -f2)
	if [[ ! (-f "/home/$user/.question/questions/$qname") ]]; then
		echo "No such question: "$user"/"$qname > /dev/stderr
		exit 1
	fi
	if [[ $3 = */* ]]; then
		echo "Invalid arguments" > /dev/stderr
		exit 1
	fi
	if [[ -f $HOME/.question/answers/$3 ]]; then
		echo "The answer id exists already" > /dev/stderr
		exit 1
	fi
	if [[ $# > 3 ]]; then
		content=$(echo $4)
	else
		read content
	fi
	if [[ $content = *====* ]]; then
		echo "question contains \"====\"" > /dev/stderr
		exit 1
	fi
	if [[ $content = "" ]]; then
		echo "empty question" > /dev/stderr
		exit 1
	fi
	assureDirExists "$HOME/.question/answers/$user/$qname"
	touch "$HOME/.question/answers/$user/$qname/$3"
	chmod 705 "$HOME/.question/answers/$user/$qname/$3"
	echo $content >> "$HOME/.question/answers/$user/$qname/$3"
	exit 0
fi

if [[ $1 == list ]]; then
	if [[ $# > 2 ]]; then
		echo "The wrong number of arguments are given to an option (too few 
			or too many)" > /dev/stderr
		exit 1
	fi
	if [[ ! $2 == "" ]]; then
		if [[ ! (-d "/home/$2/.question") ]]; then
			echo "No such user" > /dev/stderr
			exit 1
		else
			find "/home/$2/.question/questions" -maxdepth 1 -type f -exec basename {} \;
		fi
	else
		while read line; do
			for ans in $(find "/home/$line/.question/questions" -maxdepth 1 -type f -exec basename {} \;); do
				echo $line"/"$$ans
			done
		done < "/home/unixtool/data/question/users"
	fi
	exit 0
fi

if [[ $1 == vote ]]; then
	if [[ $# > 4 ]]; then
		echo "The wrong number of arguments are given to an option (too few 
			or too many)" > /dev/stderr
		exit 1
	fi
	if [[ !($2 = up || $2 = down) ]]; then
		echo "Invalid arguments" > /dev/stderr
		exit 1
	fi
	if [[ ! $3 = */* ]]; then
		echo "Invalid arguments" > /dev/stderr
		exit 1
	fi
	user=$(echo $3 | cut -d/ -f1)
	qname=$(echo $3 | cut -d/ -f2)
	if [[ ! (-f "/home/$user/.question/questions/$qname") ]]; then
		echo "No such question exists" > /dev/stderr
		exit 1
	fi
	if [[ $4 == "" ]]; then
		assureDirExists "$HOME/.question/votes/$user"
		touch "$HOME/.question/votes/$user/$qname"
		chmod 705 "$HOME/.question/votes/$user/$qname"
		sed -i -e "/^up$/d" "$HOME/.question/votes/$user/$qname"
		sed -i -e "/^down$/d" "$HOME/.question/votes/$user/$qname"
		echo $2 >> "$HOME/.question/votes/$user/$qname"
	else
		if [[ ! $4 = */* ]]; then
			echo "Invalid arguments" > /dev/stderr
			exit 1
		fi
		auser=$(echo $4 | cut -d/ -f1)
		aname=$(echo $4 | cut -d/ -f2)
		if [[ ! -f "/home/$auser/.question/answers/$user/$qname/$aname" ]]; then
			echo "The answer id does note exist" > /dev/stderr
			exit 1
		fi
		assureDirExists "$HOME/.question/votes/$user"
		touch "$HOME/.question/votes/$user/$qname"
		chmod 705 "$HOME/.question/votes/$user/$qname"
		sed -i -e "/up $auser\/$aname/d" "$HOME/.question/votes/$user/$qname"
		sed -i -e "/down $auser\/$aname/d" "$HOME/.question/votes/$user/$qname"
		echo $2" "$auser"/"$aname >> "$HOME/.question/votes/$user/$qname"
	fi
	exit 0
fi

if [[ $1 == view ]]; then
	if [ $# -ne 2 ]; then
		echo "The wrong number of arguments are given to an option (too few 
			or too many)" > /dev/stderr
		exit 1
	fi
	for file in "$@"; do
		if [[ $file == view ]]; then
			continue
		fi
		user=$(echo $file | cut -d/ -f1)
		qname=$(echo $file | cut -d/ -f2)
		if [[ ! (-f "/home/$user/.question/questions/$qname") ]]; then
			echo "No such question exists" > /dev/stderr
			exit 1
		else
			count=0
			while read usr; do
				if [[ -f "/home/$usr/.question/votes/$user/$qname" ]]; then
				 	count=$((count+$(sed -n -e "/^up$/p" "/home/$usr/.question/votes/$user/$qname" | wc -l)))
				 	count=$((count-$(sed -n -e "/^down$/p" "/home/$usr/.question/votes/$user/$qname" | wc -l)))
				fi
			done < /home/unixtool/data/question/users
			echo $count" "$user"/"$qname
			cat "/home/$user/.question/questions/$qname"
			echo "===="
			while read usr; do
				if [[ -d "/home/$usr/.question/answers/$user/$qname" ]]; then
					for ans in $(find "/home/$usr/.question/answers/$user/$qname" -type f -maxdepth 1 -exec basename {} \;); do
						count=0
						while read u; do
							if [[ -f "/home/$u/.question/votes/$usr/$qname" ]]; then
						 		count=$((count+$(sed -n -e "/up $usr\/$ans/p" "/home/$u/.question/votes/$user/$qname" | wc -l)))
						 		count=$((count-$(sed -n -e "/down $usr\/$ans/p" "/home/$u/.question/votes/$user/$qname" | wc -l)))
							fi
						done < /home/unixtool/data/question/users
						echo $count" "$usr"/"$ans" @"$user"/"$qname
						cat "/home/$usr/.question/answers/$user/$qname/$ans"
						echo "===="
					done
				fi
			done < /home/unixtool/data/question/users
		fi
	done
	exit 0
fi

echo "No such option exists" > /dev/stderr
exit 1

	

	
	
