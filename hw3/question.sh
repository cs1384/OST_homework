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
	if [[ $# > 3 ]]; then
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
	echo $content
	if [[ $content = *====* ]]; then
		echo "question contains \"====\"" > /dev/stderr
		exit 1
	fi
	if [[ $content = "" ]]; then
		echo "empty question" > /dev/stderr
		exit 1
	fi
	#assureDirExists "$HOME/question/questions"
	assureDirExists "$HOME/.question/questions"
	touch "$HOME/.question/questions/$2"
	echo $content >> "$HOME/.question/questions/$2"
	exit 0
fi

if [[ $1 == answer ]]; then
	if [[ $# > 4 ]]; then
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
	if [[ ! (-f "/Users/$user/.question/questions/$qname") ]]; then
	#if [[ ! (-f "/home/$user/.question/questions/$qname") ]]; then
		echo "No such question exists" > /dev/stderr
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
		content=$(echo $3)
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
	assureDirExists "$HOME/.question/answers/$user"
	touch "$HOME/.question/answers/$user/$3"
	echo $content >> "$HOME/.question/answers/$user/$3"
	exit 0
fi

if [[ $1 == list ]]; then
	if [[ $# > 2 ]]; then
		echo "The wrong number of arguments are given to an option (too few 
			or too many)" > /dev/stderr
		exit 1
	fi
	if [[ ! $2 == "" ]]; then
		if [[ ! (-d "/Users/$2/.question") ]]; then
		#if [[ ! (-d "/home/$2/.question") ]]; then
			echo "No such user" > /dev/stderr
			exit 1
		else
			find "/Users/$2/.question/questions" -type f -maxdepth 1 -exec basename {} \;
			#find "/home/$2/.question/questions" -type f -maxdepth 1 -exec basename {} \;
		fi
	else
		while read line; do
			find "/Users/$line/.question/questions" -type f -maxdepth 1 -exec basename {} \;
			#find "/home/$line/.question/questions" -type f -maxdepth 1 -exec basename {} \;
		done < "/Users/Tin/Study/Open Source Tool/homework/hw3/users"
		#done < /home/unixtool/data/question/users 
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
	if [[ ! (-f "/Users/$user/.question/questions/$qname") ]]; then
	#if [[ ! (-f "/home/$user/.question/questions/$qname") ]]; then
		echo "No such question exists" > /dev/stderr
		exit 1
	fi
	if [[ $4 == "" ]]; then
		assureDirExists "$HOME/.question/votes/$user"
		touch "$HOME/.question/votes/$user/$qname"
		sed -i -e "/^up$/d" "$HOME/.question/votes/$user/$qname"
		sed -i -e "/^up$/d" "$HOME/.question/votes/$user/$qname"
		echo $2 >> "$HOME/.question/votes/$user/$qname"
	else
		if [[ -f $HOME/.question/answers/$4 ]]; then
			echo "The answer id does note exist" > /dev/stderr
			exit 1
		fi
		assureDirExists "$HOME/.question/votes/$user"
		touch "$HOME/.question/votes/$user/$qname"
		sed -i -e "/up $user\/$4/d" "$HOME/.question/votes/$user/$qname"
		sed -i -e "/down $user\/$4/d" "$HOME/.question/votes/$user/$qname"
		echo $2" "$user"/"$4 >> "$HOME/.question/votes/$user/$qname"
	fi
	exit 0
fi

if [[ $1 == view ]]; then
	for file in "$@"; do
		if [[ $file == view ]]; then
			continue
		fi
		user=$(echo $file | cut -d/ -f1)
		qname=$(echo $file | cut -d/ -f2)
		if [[ ! (-f "/Users/$user/.question/questions/$qname") ]]; then
		#if [[ ! (-f "/home/$user/.question/questions/$qname") ]]; then
			echo "No such question exists" > /dev/stderr
			exit 1
		else
			count=0
			while read usr; do
				if [[ -f "/Users/$usr/.question/vote/$qname" ]]; then
				#if [[ -f "/home/$usr/.question/vote/$qname" ]]; then
				 	$count = $count + $(sed -n -i -e "/up/p" "/Users/$usr/.question/vote/$qname" | wc -l)
				 	#$count = $count + $(sed -n -i -e "/up/p" "/home/$usr/.question/vote/$qname" | wc -l)
				 	$count = $count - $(sed -n -i -e "/down/p" "/Users/$usr/.question/vote/$qname" | wc -l)
				 	#$count = $count - $(sed -n -i -e "/down/p" "/home/$usr/.question/vote/$qname" | wc -l)
				fi 
				 "/Users/$line/.question/vote/$" -type f -maxdepth 1 -exec basename {} \;
				#find "/home/$line/.question/questions" -type f -maxdepth 1 -exec basename {} \;
			done < "/Users/Tin/Study/Open Source Tool/homework/hw3/users"
			#done < /home/unixtool/data/question/users
		fi

	fi
		
		
	done

fi
	

	
	
