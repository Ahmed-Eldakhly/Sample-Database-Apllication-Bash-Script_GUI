#!/bin/bash
#----------------------------------------------------------------------
#interface with tables.
. ./create-table.sh
. ./delete-from-table.sh
. ./update-table.sh
. ./dml.sh
. ./select-from-table.sh
DELIMITER=';'
function tableMenu() {
while true
do
	tableChoice=`zenity --list --width="500" --height="500" --text "Table Actions"  --radiolist  --column "Pick" --column "Menu" FALSE "Create Table" FALSE "List Tables" FALSE "Drop Table" FALSE "Insert into Table" FALSE "Select From Table" FALSE "Delete From Table" FALSE "Update Table"`
	if [[ $? -eq 1 ]]
	then
		cd ..
		break
	fi
	case $tableChoice in
		"Create Table") createTable ;;
		"List Tables") listTables ;;
		"Drop Table") dropTable ;;
		"Insert into Table") insertIntoTable ;;
		"Select From Table") selectFromTable ;;
		"Delete From Table") deleteFromTable ;;
		"Update Table") updateTable ;;
		*) zenity --warning --title="Table Options" --width="500" --height="100" --text="Wrong choice! please choose from the above choices."
	esac
done
}
