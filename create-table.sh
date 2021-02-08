#!/bin/bash
#----------------------------------------------------------------------
#variables section
typeset -i endCreationFlag=1
typeset -i numberOfcolumnCreation=0
typeset -i columnPrimaryKeyCreation=0
printLineCreation=""
Type=""
columnNames=""
columnDatatype=""
#----------------------------------------------------------------------
#function to check if the table is exist
function thisCheckOnTableCreation(){
	tableName=`zenity --entry --title="Table Creation" --text="please insert table name to be created."`
	#check if user press cancel or ok with empty data.
        if [[ $? == 1 || ${#tableName} == 0 ]]
	then 
		endCreationFlag=0
		return		
	fi
	#check if the inserted name is exist.
	while [ -f $tableName ] 
	do
		zenity --warning --title="Table Creation"  --width="500" --height="100" --text="The table name already exist, please insert another name."
		tableName=`zenity --entry --title="Table Creation"  --text="please insert table name."`
		#check if user press cancel or ok with empty data.
		if [[ $? == 1 || ${#tableName} == 0 ]]
		then 
			endCreationFlag=0
			return		
		fi
	done 
}
#----------------------------------------------------------------------
#function to create table in new file if the user insertion has been finished with number of columns 
function saveTable(){
	#check if the user add one column at lest to avoid creation of empty tables.
	if [ $numberOfcolumnCreation -eq 0 ]
	then
		#ask the user if he want to canel table creation or add columns.
		zenity --question --title="Table Creation" --width="500" --height="100" --ok-label="Yes" --cancel-label="No" --text="No column in the table, so this table will not be created.\nAre you sure that you want to cancel the table creation process?"
	        if [[ $? == 0 ]]
		then 
			endCreationFlag=0;		
		fi
	else
		#create the table files with inserted columns, datatype, and primary key.
		touch .$tableName
		touch $tableName
		echo $columnNames >> .$tableName
		echo $columnDatatype >> .$tableName
		echo $columnPrimaryKeyCreation >> .$tableName
		zenity --notification --title="Table Creation" --text="the $tableName has been created successfully."
		endCreationFlag=0
	fi
}
#----------------------------------------------------------------------
#add Delimiter between columns after the first column
function addDelimiterToRecordCreation(){
	#check if the user added one column at least before add delimiter.
	if [[ $numberOfcolumnCreation != 0 ]]
	then
		columnNames+=$DELIMITER
		columnDatatype+=$DELIMITER
	fi
}
#----------------------------------------------------------------------
#ask the user to insert valid datatype (INT - STRING - DATE) for the new record
function getColumnDatatypeCreation(){
	while true
	do
		newColumnDatatype=`zenity --list --title="Table Creation" --height="300" --column=Menu "Integar" "String" "Date" "Password" --text="please insert new column datatype."`
		if [ $newColumnDatatype == Integar ]
		then
			columnDatatype+="INT"
			break
		elif [ $newColumnDatatype == String ]
		then
			columnDatatype+="STRING"
			break
		elif [ $newColumnDatatype == Password ]
		then
			columnDatatype+="PASSWORD"
			break
		elif [ $newColumnDatatype == Date ]
		then
			columnDatatype+="DATE"
			break
		else
			zenity --warning --title="Table Creation" --width="500" --height="100"  --text="Wrong choice."
		fi
	done
}
#----------------------------------------------------------------------
#ask the user about the primary key
function getPrimaryKeyCreation(){
	#check if this table has primary key or not.
	if [[ $columnPrimaryKeyCreation == 0 ]]
	then
		newcolumnPrimaryKeyCreation=`zenity --question --title="Table Creation" --ok-label="Yes" --cancel-label="No" --width="500" --height="100" --text="Do you want this key to be your primary key?"`
	        if [[ $? == 0 ]]
		then 
			(( columnPrimaryKeyCreation = numberOfcolumnCreation ))			
		fi
	fi
}
#----------------------------------------------------------------------
#function to create new table in current database
function createTable() {
	endCreationFlag=1
	thisCheckOnTableCreation
	while [[ $endCreationFlag == 1 ]]
	do
		userChoice=`zenity --list --title="Table Creation" --height="300" --width="400" --column=Menu "Add new column." "Create table with at least one column." "Exit without save." --text="please insert new column datatype."`
	        if [[ $? == 1 ]]
		then 
			break		
		fi
		if [[ $userChoice == "Add new column." ]]
		then
			addDelimiterToRecordCreation
			#get the new column name.
			newColumnName=`zenity --entry --title="Table Creation" --text='please insert new column name.'`
			#check if user press cancel or ok with empty data.
			if [[ $? == 1 || ${#newColumnName} == 0 ]]
			then 
				continue	
			fi
			columnNames+=$newColumnName
			getColumnDatatypeCreation
			let "numberOfcolumnCreation++"
			getPrimaryKeyCreation
		elif [[ $userChoice == "Create table with at least one column." ]]
		then
			saveTable
		elif [[ $userChoice == "Exit without save." ]]
		then
			break		
		else
			zenity --warning --title="Table Creation" --width="500" --height="100"  --text="Wrong choice."
		fi		 
	done
}

