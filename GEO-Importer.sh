#!/usr/bin/env bash
# notes: system requires dos2unix to be installed
# source txt file will have new line characters from windows
# and that will break things real good

echo
echo "##################################################"
echo "########### Nathan's Bulk GEO Importer ###########"
echo "##################################################"
echo

#==============================================================================
#=====================  Change below varialbes to suit  =======================
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
# e.g.  ./GEO-Importer.sh 84261 - ATMK TANKS.txt
fileName=$1
# using parameter expansion to get the required values from the fileName
noExtension=${fileName%%.*}
# parameter expansion "%" keeps the front information, "#" keeps the end information.
jobNumber=${noExtension%" "-*}
customer=${noExtension#*-" "}

#===============================================================================
#=== Cleaning the file because windows new line characters breaks everything ===
#===============================================================================

echo
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

#==========================================================================
#======== Creating the temp txt files and creating the ARRAY's  ===========
#==========================================================================
# initialising the array
declare -A partCodeArray
declare -A materialArray
declare -A qtyArray
# setting up the array counter
counter=0
# if statement determines which part code to useClientPartCode
# false = use the GCI part code, true = use the client part code
if [[ $useClientPartCode == false ]]; then
  # cut -f1 will take the first data on each line before a tab and
  # output that into a temp txt file
  cut -f1 "$fileName" > "$copyGeoLocation"/temp-GCI-partCode.txt
  # cut -f2 will take the second column of data on each line
  cut -f2 "$fileName" > "$copyGeoLocation"/temp-Material.txt
  # cut -f3 will atke the third column of data on each line
  cut -f3 "$fileName" > "$copyGeoLocation"/temp-QTY.txt
  # creating the parts code array
  while IFS=$'\n' read -r line_data; do
    partCodeArray[$counter]=$line_data
    ((counter++))
  done < "$copyGeoLocation"/temp-GCI-partCode.txt
  # creating the material array
  counter=0
  while IFS=$'\n' read -r line_data; do
    materialArray[$counter]=$line_data
    ((counter++))
  done < "$copyGeoLocation"/temp-Material.txt
  # creating the qty array
  counter=0
  while IFS=$'\n' read -r line_data; do
    qtyArray[$counter]=$line_data
    ((counter++))
  done < "$copyGeoLocation"/temp-QTY.txt
#else
  # yet to add the customer part code feature
  # on the to do list...
fi

#============================================================================
# All the arrays have now been created
# moving to the U Drive to find all the geo's to copy
#============================================================================

cd "$uDrive"

customerFolder=$(find -maxdepth 1 -type d -name "$customer*" -print -quit)
# if the customer does not exits the program will exit
if [[ ! -d "$customerFolder" ]]; then
  echo "Error, that customer folder for" $customer "does not exist!"
  exit 1
fi
echo
echo "The customer folder is:" $customerFolder
echo
cd "$customerFolder"/ITMS*
pwd
echo

# making the directory where all the GEO's will be copied to
mkdir "$copyGeoLocation"/$jobNumber

counter=0
for j in "${partCodeArray[@]}"
do
  for f in $(ls | grep -i ${partCodeArray[$counter]}*.GEO); do
    echo $f
    noExtension=${f%%.*}
    lineNumber=$(($counter + 1))
    cp $f "$copyGeoLocation/$jobNumber/$lineNumber - $noExtension - ${materialArray[$counter]} - x${qtyArray[$counter]}.GEO"
  done
  ((counter++))
  sleep 0.5
done

echo
echo "All GEO's have been copied!"
echo
echo "Removing the temp .txt files..."
echo
rm "$copyGeoLocation"/*.txt
echo $jobNumber "is ready to nest."
