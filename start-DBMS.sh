#!/bin/bash
#----------------------------------------------------------------------
#import Database functions to make Database definision language functions.
. database_logic.sh
clear
# logic to close the terminal and deal with the GUI only.
disown
terminalProcess=`ps | sed -n "2p" | cut -f3 -d" "`
gnome-terminal &
kill -9 $terminalProcess
#----------------------------------------------------------------------
# check if it is the first time to use the programe to create the man directory for all database.
if [ ! -d Database-schema ]
then
	mkdir Database-schema
fi
cd Database-schema
#----------------------------------------------------------------------
# loop to display the man menu till the user press cancel
while true
do
	userChoice=`zenity --list --text "Welcome to OurSQL" --radiolist  --column "Pick" --column "Menu"    FALSE "Create Database" FALSE  "List Database" FALSE  "Connect to Databases" FALSE "Drop Database"  --width="500" --height="500" --window-icon="/home/ahmed_eldakhly/Pictures/uwp305721.jpeg"`
	if [[ $? == 1 ]]
	then
		zenity --question --title="Exit From DBMS" --width="500" --height="100" --ok-label="Yes" --cancel-label="No" --text="Are you sure that you want to Exit from DBMS?"
		if [[ $? == 0 ]]
		then
			break
		fi
	fi
	case $userChoice in
	    "Create Database") createNewDatabase ;;
	    "List Database") listDatabases ;;
	    "Connect to Databases") connectDb ;;
	    "Drop Database") dropDb ;;
	esac
done
exit






