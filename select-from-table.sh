#!/bin/bash
#----------------------------------------------------------------------
# function to put the column names to the user to select from them
function getColumnNamesInArrays(){
	typeset -i index=1
	columnNameInFile=`sed -n '1p' .$table_name | sed "s/$DELIMITER/ /g"`
	index=1
 	for i in ${columnNameInFile[@]}
	do
		columnsNameArray[$index]=$i
		let "index++"
	done
	#to determine the height of the menu of columns dependes on the number of columns.
	(( heightOfColumns = index * 50 ))
}

function getSelectedColumnsFromUser(){
	ColumnInCheckList=`sed -n '1p' .$table_name | sed "s/$DELIMITER/ TRUE /g"`
	selectedColumns=`zenity  --list  --width="500" --height=$heightOfColumns --text "please select columns from the table to show data"  --checklist  --column "Pick" --column "options" TRUE $ColumnInCheckList --separator=" "` 
	selectedFields=""
	#loop to get the data the number og columns that the user selected.
	outsideLoop=1
 	for i in ${selectedColumns[@]}
	do
		insideLoop=1
		for j in ${columnNameInFile[@]}
		do
			if [ $i = $j ]
			then
				if [[ ${#selectedFields} == 0 ]]
				then
					selectedFields+=$insideLoop
				else
					selectedFields+=$DELIMITER$insideLoop
				fi
				break
			fi
			let "insideLoop++"
		done
		let "outsideLoop++"
	done
}

#function to update old records with new records
function selectFromTable() {
	#List all tables in current Database
	listTables
	#check if the user presses on cancel or in ok with empty insertion.
	if  [[ $? == 1 || ${#table_name} == 0 ]]
	then
		return
	fi
	typeset -i index=1
	#display column name to make user select which column we will search for.
	columsNameArray=`sed -n '1p' .$table_name | sed "s/$DELIMITER/ /g"`
	searchColumn=`zenity --list --title="Column Names" --height="300" --column=Menu $columsNameArray --text="please select one column to search for"`
	#check if the user presses on cancel or didn't select any column.
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
	#check if the user presses on cancel or didn't select any column.
	if  [[ $? == 1 || ${#searchValue} == 0 ]]
	then
		return
	fi
	getColumnNamesInArrays
	getSelectedColumnsFromUser
	if [[ ${#selectedFields} == 0 ]]
	then
		return
	fi
	selectLocations=`awk -v searchColumn=$searchColumn -v searchValue=$searchValue -v delimiter=$DELIMITER -v Fields=$selectedFields 'BEGIN{FS=delimiter} { if($searchColumn == searchValue){StringLine = " "; arrayLength = split(Fields , arr , delimiter); for(i = 1; i <= arrayLength; i++){if(i != arrayLength){StringLine = StringLine$arr[i]delimiter}else{StringLine = StringLine$arr[i]}}print StringLine}}' $table_name`
	typeset -i counter=0
	#loop to check if any record matched with the inserted data.
 	for i in ${selectLocations[@]}
	do
		(( counter++ ))
	done
	if [[ $counter == 0 ]]
	then
		zenity --warning --title="Table Creation" --width="500" --height="100"  --text="No matched record."
	else
		selectedColumns=`echo $selectedColumns | sed "s/ / --column=/g"`
		selectLocations=`echo $selectLocations | sed "s/$DELIMITER/ /g"`
		zenity  --list  --text "Selected Data" --width="500" --height="500" --column=$selectedColumns $selectLocations
		return
	fi	
}

	








