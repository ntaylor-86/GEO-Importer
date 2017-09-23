#!/usr/bin/env bash

#==============================================================================
#=====================  Change these varialbes to suit  =======================
#==============================================================================

uDrive="/home/ubuntu/U-Drive"
copyGeoLocation="/home/ubuntu/U-Drive/GEOs-Ready-Nest"

# the default value is false, most of the customers use the GCI part code scheme
# EXPR1234, VARL1234 etc, etc. Bustech and Redmond Gary use their part code
useClientPartCode=false

#=================================================================
#====  Gathering the required information from the file name  ====
#=================================================================

# $1 is getting the file from the command
# e.g.  ./GEO-BULK-IMPORT.sh 84261 - ATMK TANKS.txt
fileName=$1
# using parameter expansion to get the required values from the fileName
noExtension=${fileName%%.*}
# parameter expansion "%" keeps the fron information, "#" keeps the end information.
jobNumber=${noExtension%" "-*}
customer=${noExtension#*-" "}

#===========================================================
#== Cleaning the file because windows new line characters ==
#===========================================================

dos2unix "$fileName"

#===========================================================

echo
echo "The File Name = " $noExtension
echo "The Job number from the file name is =" $jobNumber
echo "The customer from the file name is = " $customer

#============================================================================
#====  Testing whether to use the client part code or the GCI part code  ====
#============================================================================

# prob going to change how this is done
# maybe create an array with all the customers in it
# and loop though it to test???

if [[ "$customer" == "BUSTECH" ]]; then
  useClientPartCode=true
elif [[ "$customer" == "EXPRESS COACH" ]]; then
  useClientPartCode=true
elif [[ "$customer" == "ATM TANKS" ]]; then
  useClientPartCode=true
fi

#============================================================================
#======== Creating the temp txt file and creating the partCodeArray  ========
#============================================================================

# initialising the array
declare -A partCodeArray
# setting up the array counter
counter=0
# if statement determines which part code to useClientPartCode
# false = use the GCI part code, true = use the client part code
if [[ $useClientPartCode == false ]]; then
  # cut -f1 will take the first data on each line before a tab and
  # output that into a temp txt file
  cut -f1 "$fileName" > "$copyGeoLocation"/temp-GCI-partCode.txt
  # while loop that takes each line from the txt file and adds it into the part code array
  while IFS=$'\n' read -r line_data; do
    partCodeArray[$counter]=$line_data
    ((counter++))
  done < "$copyGeoLocation"/temp-GCI-partCode.txt
else
  cut -f2 "$fileName" > "$copyGeoLocation"/temp-CUSTOMER-partCode.txt
fi

echo
echo "Listing all the parts in the array"
echo
counter=0
for i in "${partCodeArray[@]}"
do
  echo ${partCodeArray[$counter]}
  ((counter++))
done


#============================================================================

#while read p || [[ -n $p ]]; do
#  echo "$p"
#done < "$fileName"


cd "$uDrive"

customerFolder=$(find -maxdepth 1 -type d -name "$customer*" -print -quit)
if [[ ! -d "$customerFolder" ]]; then
  echo "Error, that customer folder for" $customer "does not exist!"
  exit 1
fi
echo
echo "The customer folder is:" $customerFolder
echo
cd "$customerFolder"/ITMS*
pwd
currentDir=${PWD}
echo

counter=0
for j in "${partCodeArray[@]}"
do
  echo "Copying" ${partCodeArray[$counter]}
  lineNumber=$(($counter + 1))
  cp ${partCodeArray[$counter]}*.[gG][eE][oO] "$copyGeoLocation/$lineNumber-.GEO"
  ((counter++))
  sleep 0.5
done
