#!/bin/bash
#----------------------------------------------------------------------
#function to delete record from the table.
function deleteFromTable() {
	#List all tables in current Database
	listTables
	#check if the user presses on cancel or in ok with empty insertion.
	if  [[ $? == 1 || ${#table_name} == 0 ]]
	then
		return
	fi
	typeset -i index=1
	#display column name to make user select which column we will search for to delete its record.
	columsNameArray=`sed -n '1p' .$table_name | sed "s/$DELIMITER/ /g"`
	searchColumn=`zenity --list --title="Column Names" --height="300" --column=Menu $columsNameArray --text="please select one column to search for"`
	#check if the user presses on cancel.
	if  [[ $? == 1 || ${#searchColumn} == 0 ]]
	then
		return
	fi
	#loop to get the number of selected column.
 	for i in ${columsNameArray[@]}
	do
		if [[ $i == $searchColumn ]]
		then
			searchColumn=$index
			break
		fi
		let "index++"
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
	#check if the user presses on cancel.
	if  [[ $? == 1 ]]
	then
		return
	fi
	deleteLocations=`awk -v searchColumn=$searchColumn -v searchValue=$searchValue -v delimiter=$DELIMITER 'BEGIN{FS=delimiter} { if($searchColumn == searchValue){ print NR," "}}' $table_name`
	typeset -i index=0
	#check if any record matched.
	if [[ ${#deleteLocations} == 0 ]]
	then
		zenity --warning --title="Delete from table" --width="500" --height="100"  --text="No matched record."
	else
		#loop to delete all records that matched with the user input.
		for i in $deleteLocations
		do
			(( deletedLine = $i - $index ))	
			sed -i "${deletedLine}d" $table_name
			let "index++"
		done 
		zenity --notification --title="Delete from table" --text="delete record(s) has finished successfully."
	fi
}




