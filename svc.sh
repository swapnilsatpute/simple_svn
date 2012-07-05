#!/bin/sh

isNumeric() 
{ 
  echo "$1" | grep -q -v "[^0-9]"
}

displaySelectedVersionImage()
{
	
	if (grep -q -w $1 key_log)
	then 
		cat v$1	
	else	
	
		src=0
		line=2
		
		if [ $1 -gt $(tail -n 1 key_log) ]
		then
			src=$(tail -n 1 key_log)	
		else	
			while [ $(head -n $line key_log | tail -n 1) -lt $1 ] 
			do
								
				line=`expr $line + 1`			
					
			done
					
			
			src=$(head -n $(($line - 1)) key_log | tail -n 1)
		fi

			echo "Base source $src selected"	
			
			cat v$src > tmp
	
			
			patch -u -s tmp v$1
			

			cat tmp
			rm tmp	
	fi
}

initSVN()
{
 	echo "init: version 0"
	mkdir .version
	echo "0" > .version/key_log	
	cat $1 > .version/v0
}


commit()
{
				
	next_version=$(( $(ls .version/ | tail -n 1| cut -c 2-) + 1 ))
	echo "last version is $(($next_version - 1))"			
	
	echo "commiting version $next_version"
			
		
	diff -u .version/v$(tail -n 1 .version/key_log) $1 > .version/tmp
		#difference wrt last key
#blank temp then no change	
	
	if [ $(( $(grep ^[-+] .version/tmp | wc -l) - 2)) -gt 10 ]
	then		
		cat $1 > .version/v$next_version
		echo "$next_version" >> .version/key_log
	else
		cat .version/tmp > .version/v$next_version
	fi
	
	rm .version/tmp		
	
	echo "commited version $next_version"
}


if [ $# != 1 ]
then
   echo "Usage:\n\t svc filename \n\t svc version"
   exit 1
fi


if (isNumeric $1)
then
	echo "version_mode"
	if [ -d .version ]
	then
		cd .version	
	else	
		echo "error:subversion not initialised"	
		exit 4 	
	fi	
	
	if [ -f "v$1" ]
        then
		echo "version_exists\nDisplay:\n"
		
		displaySelectedVersionImage $1		
		
	else 
		echo "error:version $1 not found"	
		exit 2
	fi

else
	echo "commit_mode"
	
	if [ -f "$1" ]
        then        
		if [ -d ".version" ]
        	then 		
			commit $1			
		else
			initSVN $1				
		fi
	else 
		echo "error:file $1 not found"	
		exit 3
	fi

fi
