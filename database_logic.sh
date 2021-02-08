#!/bin/bash
#----------------------------------------------------------------------
#import helper functions
. ddl.sh
. dml.sh
. table-menu.sh
#----------------------------------------------------------------------
#create new database with new name.
function createNewDatabase(){
	while true
	do
		#take the name of Database from the user
 		db_name=`zenity --entry --title="Database creation" --text="please write the name of new Databese"`
		#check if the user press on cancel.
		if  [[ $? == 1 || ${#db_name} == 0 ]]
		then
			break
		fi
		#if Database exists so ask user to reinsert it, if not, add the database to the database schema.
		if [ -d $db_name ]
		then
			zenity --warning --title="Create Databases" --width="500" --height="100" --text="The name of Database is used with another Database."
		else
			mkdir $db_name
			mkdir $db_name'/.trash'
			zenity --notification --title="Database creation" --text="The New Database has been created successfully."
			break
		fi
	done
}
#----------------------------------------------------------------------
#make a list with all databases i the database schema.
function listDatabases () {
	#check if the database schema is empty to return warning message or display all databases to the user.
	typeset databaseList=`ls | wc -l`
	if [ $databaseList -eq 0 ]
	then 
		zenity --warning --title="List of Databases" --width="500" --height="100" --text="No Database exists yet."
	else
		(( databaseList *= 100 ))
		db_name=$(zenity --list --width="500" --height=$databaseList \
		  --title="List of Databases" \
		  --column="Database Names" \
		  `ls -1`)
	fi
}
#----------------------------------------------------------------------
#connect with database to deal with tables inside it and do DML on the database.
function connectDb(){
	#List Database to make user select.
	listDatabases
	#check if the user presses on cancel or in ok with empty insertion.
	if  [[ $? == 1 || ${#db_name} == 0 ]]
	then
		return
	fi
	#connect with Database and enter it and display table menu.
	useDb $db_name
	zenity --notification --title="Connect with Database" --text="[] Connection established"
	tableMenu;
}
#----------------------------------------------------------------------
#remove database from the schema if it exists.
function dropDb(){
	#List Database to make user select.
	listDatabases
	#check if the user presses on cancel or in ok with empty insertion.
	if  [[ $? == 1 || ${#db_name} == 0 ]]
	then
		return
	fi
	#check if database is empty or not to delete it or ask the user question if he want to lose all data.
	isDbEmpty $db_name
	isEmpty=$?
	if [ $isEmpty -eq 1 ]
	then
	        rm "-dr" $db_name
		zenity --notification --title="Drop Database" --text="Empty schema.\nDatabase has been dropped successfully."
	else
		zenity --question --title="Drop Database" --width="500" --height="100" --ok-label="Yes" --cancel-label="No" --text="Database is not empty. Do you want to remove the database with its tables?"
	        if [[ $? == 0 ]]
	            then 
	                rm "-dr" $db_name
	                zenity --notification --title="Drop Database" --text="Database has been dropped successfully."
	        fi
	fi
}








