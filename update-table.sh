#!/bin/bash
#----------------------------------------------------------------------
#import helper functions
. dml.sh
# variables section
typeset -i index=1

# function to put the column names and column datatype in array to display them to the user to select from them
function getColumnNamesAndDatatypeInArraysToUpdate(){
	columnNameInFile=`sed -n '1p' .$table_name | sed "s/$DELIMITER/ /g"`
	columnDatatypeInFile=`sed -n '2p' .$table_name | sed "s/$DELIMITER/ /g"`
	columnPrimaryKey=`sed -n '3p' .$table_name`
	radio_string=''
	index=1
 	for i in ${columnNameInFile[@]}
	do
		columnsNameArray[$index]=$i
		columnsDatatypeArray[$index]=${columnDatatypeInFile[@]}
		radio_string+=" $index $i "
		let "index++"
	done
}

# check if the user inserts duplicated primary key. 
function checkOnPrimaryKey(){
	currentValueOfPrimaryKey=`echo $1 | cut -f$columnPrimaryKey -d$DELIMITER`
	checkOnPrimaryKey=`cut -f$columnPrimaryKey -d$DELIMITER $table_name | grep "$newData" | wc -l`
	if [[ ($checkOnPrimaryKey == 0 || $currentValueOfPrimaryKey == $newData) && ${#newData} > 0 ]]
	then
		replaceStatement+=$newData
		columnUpdated=1
	else
		check=`zenity --warning --title="Not matched" --width="500" --height="100"  --text="Duplicated value for primary key"`
	fi
}

# function to over write the old record with the new record with making validation on the inserted datatype of columns
function replaceRecordInTable(){
	#get cloumns name, columns datatype, and the primary key if it exists.
    	local length=$(head -n 1 .$table_name | tr $DELIMITER ' ' | wc -w)
	local columns_names=($(head -n 1 .$table_name | tr $DELIMITER ' '))
	local columns_types=($(head -n 2 .$table_name | tail -n 1 | tr $DELIMITER ' '))
	local pkColNum=$(tail -n 1 .$table_name )
	local new_record=()
	printTableColums=`head -n 1 .$table_name`
	zen_col=''
	#form the form constructure from columns datatype.
	for (( i=0; $i < $length; i++ ))
	do
		if [ ${columns_types[$i]} == "DATE" ]
		then
			zen_col+="--add-calendar=${columns_names[$i]} --forms-date-format=%Y-%m-%d "
		elif  [[ ${columns_types[$i]} == "PASSWORD" ]]
		then
			zen_col+="--add-password=${columns_names[$i]} "
		else
			zen_col+="--add-entry=${columns_names[$i]} "
		fi
	done
	while true
	do
		#create form to make user insert new record.
		#get old record to display it to the user while updating process.
		OldRecord="\n"`echo $1 | sed "s/$DELIMITER/\n/g"`"\n"
		cellValue=(`zenity --forms --title=$table_name --text="The old record is $OldRecord\nThe new record is\nNote: Don't use spaces and use null for empty Data, otherwise Data will not be accepted." $zen_col --separator=" "`)
		#check if the user presses on cancel.
		if  [[ $? == 1 ]]
		then
			return
		#in case some fields are empty or contain spaces.
		elif [[ ${#cellValue[@]} != $length ]]
		then
			zenity --warning --title="Wrong insertion" --width="500" --height="100" --text="Some Fields are Empty or included spaces."
			continue
		fi
		new_record=()
		#loop the validate all inserted data and check if primary key is doublicated.
		for (( i=0; $i < $length; i++ ))
		do
			#check on validation of INT or DATE.
			if [[ (( ${columns_types[$i]} == INT && ! ${cellValue[$i]} =~ ^[0-9]+$ )) || (( ${columns_types[$i]} == DATE && ${cellValue[$i]} != `date -d ${cellValue[$i]} '+%Y-%m-%d' 2> /dev/null` )) ]]
			then
				zenity --warning --title="Wrong insertion" --width="500" --height="100" --text="Wrong Datatype Insertion"
				break
			fi
			#check on primary key column
			if [ $i -eq `expr $pkColNum - 1` ]
			then
				#check if the inserted primary key exists in the table or not.
				if (( `cut -d$DELIMITER -f $pkColNum $table_name | grep ${cellValue[$i]} | wc -l` > 0 ))
				then
					#check if inserted primary key is the same of the primary key of updated record or not to accept it if they are the same.
					if [[ `echo $1 | cut -f$pkColNum -d$DELIMITER` != ${cellValue[$i]} ]]
					then
						zenity --warning --title="Wrong insertion" --width="500" --height="100" --text="The Primary key is duplicated in different record (not the updated), please insert new value"
						break
					fi
				elif [[   `echo "${cellValue[$i]}" | tr '[:upper:]' '[:lower:]'` == "null" ]]
				then
					zenity --warning --title="Wrong insertion" --width="500" --height="100" --text="The Primary key can't be null"
					break	
				fi
			fi
			new_record+=(${cellValue[$i]})
		done
		#check if all inserted data is accepted.
		if [[ $i == $length ]]
		then
			break
		fi
	done
	#replace the new record to the table.
	currentReplace=`echo ${new_record[@]} | tr " " $DELIMITER`
	sed -i "0,/$1/s//$currentReplace/" $table_name
}

#function to update old records with new records
function updateTable() {
	#List all tables in current Database
	listTables
	#check if the user presses on cancel or in ok with empty insertion.
	if  [[ $? == 1 || ${#table_name} == 0 ]]
	then
		return
	fi
	getColumnNamesAndDatatypeInArraysToUpdate

	colomnChoice=$(zenity  --list  --width="500" --height="500" --text "Table Columns" --radiolist  --column "Pick" --column "options" $radio_string);
	#check if the user presses on cancel or in ok with empty insertion.
	if  [[ $? == 1 || ${#colomnChoice} == 0 ]]
	then
		return
	fi
	searchColumn=0
	for i in "${!columnsNameArray[@]}"; do
		if [[ "${columnsNameArray[$i]}" = "${colomnChoice}" ]]; then
			searchColumn=${i};
		fi
	done
	#display the suitable insertion dialog for datatype
	searchDatatype=`sed -n '2p' .$table_name | cut -f$searchColumn -d$DELIMITER`
	if [[ $searchDatatype == "DATE" ]]
	then
		searchValue=`zenity --calendar --date-format=%Y-%m-%d --title="get value to search for" --text="Please enter the value to search for."`
	elif  [[ $searchDatatype == "PASSWORD" ]]
	then
		searchValue=`zenity --password --title="get value to search for" --text="Please enter the value to search for."`
	else
		searchValue=`zenity --entry --title="get value to search for" --text="Please enter the value to search for."`
	fi
	#check if the user presses on cancel or in ok with empty insertion.
	if  [[ $? == 1 || ${#table_name} == 0 ]]
	then
		return
	fi
	replaceLocations=`awk -v searchColumn=$searchColumn -v searchValue=$searchValue -v delimiter=$DELIMITER 'BEGIN{FS=delimiter} { if($searchColumn == searchValue){ print $0}}' $table_name`
	typeset -i counter=0
 	for i in ${replaceLocations[@]}
	do
		(( counter++ ))
	done
	#check if any record matched.
	if [[ $counter == 0 ]]
	then
		check=`zenity --warning --title="Not matched" --width="500" --height="100"  --text="Didn't find records"`
	elif [[ $counter == 1 ]]
	then
		replaceRecordInTable $replaceLocations
		check=`zenity --notification --title="Successful" --width="500" --height="100"  --text="The table has been updated"`
	else
		zenity --warning --title="Successful" --width="500" --height="100"  --text="the matched records are $counter records, you will update all of them"
		#loop to delete all records that matched with the user input.	 	
		for j in ${replaceLocations[@]}
		do
			replaceRecordInTable $j
		done
		check=`zenity --notification --title="Successful" --width="500" --height="100"  --text="The table has been updated"`
	fi		
}








