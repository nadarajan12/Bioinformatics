#!/bin/bash

###########################################################
#
#	Author: Nadarajan Kuzhandaivelu
#   Email: nadarajanvelu@gmail.com
#   Date:  Nov 27, 2020
#
##########################################################
function getSequence {
	#echo $1
	FILE=chr"$1".fa

	if ! [ -f  "$FILE" ]; then
		URL="http://hgdownload.cse.ucsc.edu/goldenPath/hg38/chromosomes/chr$1.fa.gz" #Construct the donload URL
		curl --output -  "${URL}"  | gunzip -c > chr"$1".fa #Download the sequence
		#curl -sS -o - "${URL}" | gunzip -c > chr"$1".fa # Could have used this instead of --output as in the previous line
	fi

	RESULT=$(seqtk comp "$FILE") #This is a modern operator. Could have also used back tick.	

	awk '{x=$2}END{print "Total Nucleotides: " x}' <<< "$RESULT" #Total nucleotides in cloumn 2
	awk '{x=$9}END{print "Total Unknown Nucleotides: " x}'  <<< "$RESULT" #Nucleotides marked N in cloumn 9
	awk '{x=$9 ; y=$2}END{print "Percent of Unknown Nucleotides: " sprintf("%.2f", (x/y)*100)}'  <<< "$RESULT" #Percentage of N
}


USAGE='Usage: ./GetUnknownPercent.sh -c [1-22] or xX or yY'

while getopts c: OPTION ; do
	#echo "Enter a number between 1-22 or the letters X or Y"
	case $OPTION in
		c) chromosome="$OPTARG" 
		   regex='^[0-9]+$'
		    if [[ $chromosome =~ $regex ]] #Input is numeric
			then
				if [ $chromosome -gt 0 -a $chromosome -lt 23 ]
					then
						getSequence $chromosome
					else
						echo "Your input is invalid!"
						echo "$USAGE"
						exit 1
				fi
			else
			 	if [ $chromosome = "y" ] || [ $chromosome = "Y" ]
				then 
					getSequence ${chromosome^^} #Convert to upper case
				elif [ $chromosome = "x" ] || [ $chromosome = "X" ]
				then 
					getSequence ${chromosome^^} #Convert to upper case
				else
					echo "Your input is invalid!"
					echo "$USAGE"
					exit 1
				fi
			fi
			;;
		\?) echo "$USAGE" ;
			exit 1
		;;
	esac
done