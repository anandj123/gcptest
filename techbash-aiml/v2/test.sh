#!/bin/bash

# prints colored text
print_style () {

    if [ "$2" == "info" ] ; then
        COLOR="96m";
    elif [ "$2" == "success" ] ; then
        COLOR="92m";
    elif [ "$2" == "warning" ] ; then
        COLOR="93m";
    elif [ "$2" == "danger" ] ; then
        COLOR="91m";
    else #default color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR" "$1";
}


i01=1
TASK_DESC="I01_Get_tar_file_and_extract.\n"
COLOR="Not Started"
case $i01 in
    1)
    COLOR="warning"
    ;;
    2)
    COLOR="success"
esac
print_style $TASK_DESC $COLOR

i01=2

COLOR="Not Started"
case $i01 in
    1)
    COLOR="warning"
    ;;
    2)
    COLOR="success"
esac
print_style $TASK_DESC $COLOR

export SRC_DIR="$HOME/gcptest/techbash-aiml/"
sh test2.sh > logs/test2.log 2>&1 &