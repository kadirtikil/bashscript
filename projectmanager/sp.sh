#!/bin/bash
clear
echo -e "\e[33m"  # Green color

cat << "EOF"

██████╗ ██████╗  ██████╗      ██╗███████╗ ██████╗████████╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗     
██╔══██╗██╔══██╗██╔═══██╗     ██║██╔════╝██╔════╝╚══██╔══╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗    
██████╔╝██████╔╝██║   ██║     ██║█████╗  ██║        ██║       ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝    
██╔═══╝ ██╔══██╗██║   ██║██   ██║██╔══╝  ██║        ██║       ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗    
██║     ██║  ██║╚██████╔╝╚█████╔╝███████╗╚██████╗   ██║       ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║    
╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝       ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝                                                      
EOF
echo -e "\e[0m"  # Reset color
echo -e "\e[32m"
cat << "EOF"
USE IT TO OPEN PROJECTS IN VSCODE FAST. ADD OR DELETE PROJECTS AS YOU WISH.
AFTER ADDING A PROEJCT, THE SCRIPT WILL CREATE A DIRECTORY IN THAT NAME AND
OPEN IT IN VSCODE.    !!!NOTE THAT DELETE WILL DELTETE THE WHOLE PROJECT!!!
EOF
echo -e "\e[0m"  # Reset color
# declaring base vars
base=~/Projects
# dictonairy as assoc arr
# contains project name and the dir relative to base
declare -A project_and_dir
# MAPFILE such that i can move the exe to bin and it still reads from here
MAP_FILE="$HOME/shellscripts/projectmanager/map_values.txt"

addProjectToMap() {
    local key=$1
    local value=$2
    if [[ -v project_and_dir["$key"] ]]; then
        echo "Project already exists!"
        exit
    else
        echo "$key=$value" >>  "$MAP_FILE" 
        mkdir $base/$value
        readMapTxt
        return
    fi
}

readMapTxt() {
    while IFS="=" read -r key value; do 
        project_and_dir["$key"]="$value"
    done < "$MAP_FILE" 
}

printKeys() {
    echo -e "\e[35m"
    for key in "${!project_and_dir[@]}"; do
        echo "$key"
    done
    echo -e "\e[0m"
}

serveProjectsAndDirs() {
    echo "Hello, which project would you like to start?"
    printKeys        
}


openProjectFromMap() {
    local key=$1
    echo "Opening project..."
    code "$base/${project_and_dir[$key]}"
    cd "$base/${project_and_dir[$key]}"
    exit
}

replaceMapTxt() {
    > "$MAP_FILE" 

    for key in "${!project_and_dir[@]}"; do
        echo "$key=${project_and_dir[$key]}" >> "$MAP_FILE" 
    done
    readMapTxt
}

deleteRow() {
    local DEL=$1
    if [[ -v project_and_dir["$DEL"] ]]; then
        rm -r $base/${project_and_dir[$DEL]}
        unset project_and_dir["$DEL"]
        replaceMapTxt
    else
        echo "Project cannot be deleted because it does not exist!"
    fi
}

readMapTxt

# say hallihello
INPUT=""
while [ "$INPUT"!="tschö" ]; do
    echo -e "\e[36m"
    echo "Possible options are: OPEN (o); ADD (a); DELETE (d); QUIT (q);"
    echo "Waiting on input: "; read INPUT
    case $INPUT in
        "OPEN" | "o")
            serveProjectsAndDirs   
            echo "Waiting on input: "; read PROJ 
            # check if input exists in the map
            # if so open it
            if [[ -v project_and_dir["$PROJ"] ]]; then 
                openProjectFromMap $PROJ 
            else 
                echo "not possible"
                exit
            fi
            exit
            ;;
        "ADD" | "a")
            echo "Waiting on the name of the project: "; read addkey;
            echo "Waiting for dir of project, relative to $base for $addkey"; read addvalue
            addProjectToMap $addkey $addvalue
            ;;
        "DELETE" | "d")
            echo "The following projects can be deleted:"
            printKeys 
            echo "Waiting on input: "; read DEL 
            deleteRow "$DEL"
            ;;
        "QUIT" | "q")
            echo "Quitting out"
            exit
            ;;
        *)
            echo "invalid input"
            exit
            ;;
        esac
    echo -e "\e[31m"
done



