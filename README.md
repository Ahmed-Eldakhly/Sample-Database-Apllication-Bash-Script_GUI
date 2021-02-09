# Simple Database GUI Application

<p align="center">

<img src="ReadMe-Photos/Logo.png">

</p>


# Team Members

## Ahmed Eldakhly.
## Mostafa Yossef.
            
#

# Repository Link.
[Simple Database System With GUI](https://github.com/Ahmed-Eldakhly/Sample-Database-Apllication-Bash-Script_GUI.git)

#

# Operations with Photos

## Run the application.
Using terminal run RunMe.sh file.

![GitHub in an image](ReadMe-Photos/RunMe.png)

Now The application will work with for main functions.

![GitHub in an image](ReadMe-Photos/StartMenu.png)

#

# Main Functions.

## 1 - Create Database.
This option ask the user for the name of database and if it didn't exist before, the application will create it as a folder inside Database schema folder.

![GitHub in an image](ReadMe-Photos/CreateDatabase.png)

## 2 - List Databases.
This option makes a list for all Databases in the application.

![GitHub in an image](ReadMe-Photos/ListDatabases.png)


## 3 - Drop Databases.
This option remove Databases from the system.

![GitHub in an image](ReadMe-Photos/ListDatabases.png)

## 4 - Connect Databases.
This option display all databases for the user to select and give the user access on the selected database tables.

![GitHub in an image](ReadMe-Photos/TableMenu.png)

#

# Operations on Tables.

## 1 - Create Tables.
This option ask the user for the name of Table and if it didn't exist before, the application will create it as a 2 files inside current Database folder (.TableName "Meta Data" - TableName) and start to ask the user to add new columns and its datatype (Integar - String - Date - Password) and ask the user about the primary key.

![GitHub in an image](ReadMe-Photos/CreatColumns.png) 

![GitHub in an image](ReadMe-Photos/SelectDatatype.png)

![GitHub in an image](ReadMe-Photos/AskPrimaryKey.png)

## 2 - List Tables.
This option makes a list for all Tables in the application.

![GitHub in an image](ReadMe-Photos/ListTables.png)


## 3 - Drop Tables.
This option move tables file to trash folder inside the Database. 

NOTE: The user can return it manually from the trash or delete it forever.

![GitHub in an image](ReadMe-Photos/ListDatabases.png)

## 4 - Insert into table.
This option gives the user the ability to insert new record after selecting the table from the menu of table with many checks (datatype check , primary key check , no null for primary key , no empty fields check and no space in the same field).

![GitHub in an image](ReadMe-Photos/InsertData.png)


## 5 - Select from table.
Ask the user about specific column and specific value to search for, the he can select which data will be displayed from columns name menu.

![GitHub in an image](ReadMe-Photos/SelectColumnToSearch.png)

![GitHub in an image](ReadMe-Photos/InsertDataToSearch.png)

![GitHub in an image](ReadMe-Photos/SelectColumnsToDisplay.png)

![GitHub in an image](ReadMe-Photos/SelectResult.png)


## 6 - Delete from table.
Ask the user about specific column and specific value to search for, then delete all matched records.

![GitHub in an image](ReadMe-Photos/SelectColumnToSearch.png)

![GitHub in an image](ReadMe-Photos/InsertDataToSearch.png)


## 7 - Update table.
Ask the user about specific column and specific value to search for, then update all matched records one by one with all checks and display old values if he dosen't want to update any value of them.

![GitHub in an image](ReadMe-Photos/SelectColumnToSearch.png)

![GitHub in an image](ReadMe-Photos/InsertDataToSearch.png)

![GitHub in an image](ReadMe-Photos/Update.png)

#

# Project files.

1 - RunThis.sh

2 - start-DBMS.sh

3 - database_logic.sh

4 - ddl.sh

5 - table-menu.sh

6 - dml.sh

7 - create-table.sh

8 - delete-from-table.sh

9 - select-from-table.sh

10 - update-table.sh

# 

# Sample of codes.
Sample for Bash shell script files.
```
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
```

#
