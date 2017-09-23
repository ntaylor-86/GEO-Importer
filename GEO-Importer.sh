#!/usr/bin/env bash

#==============================================================================
#=====================  Change these varialbes to suit  =======================
#==============================================================================

uDrive="/media/ubuntu/KINGSTON/Work Shell Scripts/GEO-BULK-IMPORT/U-Drive"
copyGeoLocation="/media/ubuntu/KINGSTON/Work Shell Scripts/GEO-BULK-IMPORT/U-Drive/GEOs-Ready-Nest"

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

echo
echo "The File Name = " $noExtension
echo "The Job number from the file name is =" $jobNumber
echo "The customer from the file name is = " $customer
echo

#============================================================================
#====  Testing whether to use the client part code or the GCI part code  ====
#============================================================================

if [[ "$customer" == "BUSTECH" ]]; then
  useClientPartCode=true
elif [[ "$customer" == "EXPRESS COACH" ]]; then
  useClientPartCode=true
elif [[ "$customer" == "ATM TANKS" ]]; then
  useClientPartCode=true
fi

if [[ $useClientPartCode == false ]]; then
  cut -f1 "$fileName" > "$copyGeoLocation"/temp-GCI-partCode.txt
else
  cut -f2 "$fileName" > "$copyGeoLocation"/temp-CUSTOMER-partCode.txt
fi

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
cd "$customerFolder"
pwd
echo
