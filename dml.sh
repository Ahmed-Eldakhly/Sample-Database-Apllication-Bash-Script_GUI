#!/bin/bash
#----------------------------------------------------------------------
# variables section
#insert records in connected Database tables
function insertIntoTable(){
	#List all tables in current Database
	listTables
	#check if the user presses on cancel or in ok with empty insertion.
	if  [[ $? == 1 || ${#table_name} == 0 ]]
	then
		return
	fi
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
		cellValue=(`zenity --forms --title=$table_name --text="Note: Don't use spaces and use null for empty Data, otherwise Data will not be accepted.\nColumns" $zen_col --separator=" "`)
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
			#check on primary key
			if [ $i -eq `expr $pkColNum - 1` ]
			then
				if (( `cut -d$DELIMITER -f $pkColNum $table_name | grep ${cellValue[$i]} | wc -l` > 0 ))
				then
					zenity --warning --title="Wrong insertion" --width="500" --height="100" --text="The Primary key is duplicated, please insert new value"
					break
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
	#add the new record to the table.
	echo ${new_record[@]}$EOF | tr " " $DELIMITER >> $table_name
	zenity --notification --title="Inserting" --text="Row inserted successfully."
}
#----------------------------------------------------------------------
#Display Tables in Database
function listTables(){
	#check if the database is empty to return warning message or display all tables in database.
	typeset tablesList=`ls | wc -l`
	if [ $tablesList -eq 0 ]
	then 
		zenity --warning --title="List of Tables" --width="500" --height="100" --text="No Tables exists yet."
	else
		(( tablesList *= 100 ))
		table_name=$(zenity --list --width="500" --height=$tablesList \
		  --title="List of Tables" \
		  --column="Tables Names" \
		  `ls -1`)
	fi
}
#----------------------------------------------------------------------
#drop Table from Database
function dropTable(){
	listTables
	if  [[ ${#table_name} == 0 ]]
	then
		return
	fi
        mv $table_name .$table_name .trash
	zenity --notification --title="Drop Table" --text="Done."
}
