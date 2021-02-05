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
i01=0
i02=0
f01=0
f03=0
f04=0
f05=0
f06=0
s01=0
s02=0
get_status() {
    i01=0
    i02=0
    f01=0
    f03=0
    f04=0
    f05=0
    f06=0
    s01=0
    s02=0

    if [ -f "triggers/i01.s" ]
    then
        i01=1
    fi
    if [ -f "triggers/i01.f" ]
    then
        i01=2
    fi

    if [ -f "triggers/i02.s" ]
    then
        i02=1
    fi
    if [ -f "triggers/i02.f" ]
    then
        i02=2
    fi

    if [ -f "triggers/f01.s" ]
    then
        f01=1
    fi
    if [ -f "triggers/f01.f" ]
    then
        f01=2
    fi

    if [ -f "triggers/f02.s" ]
    then
        f02=1
    fi
    if [ -f "triggers/f02.f" ]
    then
        f02=2
    fi

    if [ -f "triggers/f03.s" ]
    then
        f03=1
    fi
    if [ -f "triggers/f03.f" ]
    then
        f03=2
    fi

    if [ -f "triggers/f04.s" ]
    then
        f04=1
    fi
    if [ -f "triggers/f04.f" ]
    then
        f04=2
    fi

    if [ -f "triggers/f05.s" ]
    then
        f05=1
    fi
    if [ -f "triggers/f05.f" ]
    then
        f05=2
    fi

    if [ -f "triggers/f06.s" ]
    then
        f06=1
    fi
    if [ -f "triggers/f06.f" ]
    then
        f06=2
    fi

    if [ -f "triggers/s01.s" ]
    then
        s01=1
    fi
    if [ -f "triggers/s01.f" ]
    then
        s01=2
    fi

    if [ -f "triggers/s02.s" ]
    then
        s02=1
    fi
    if [ -f "triggers/s02.f" ]
    then
        s02=2
    fi
}
print_status() {

    get_status

    TASK_DESC="I01: Get tar file and extract"
    COLOR="Not Started"
    case $i01 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR
    
    TASK_DESC="I02: Git Cloned"
    COLOR="Not Started"
    case $i02 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

    TASK_DESC="F01: Create pubsub topics and buckets"
    COLOR="Not Started"
    case $f01 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

    TASK_DESC="F02: Create BQ tables and query them."
    COLOR="Not Started"
    case $f02 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

    TASK_DESC="F03: Cloud run build and submit."
    COLOR="Not Started"
    case $f03 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

    TASK_DESC="F04: Run dataflow job."
    COLOR="Not Started"
    case $f04 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

    TASK_DESC="F05: POST ecommerce files to cloudrun endpoint."
    COLOR="Not Started"
    case $f05 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

    TASK_DESC="F06: User input."
    COLOR="Not Started"
    case $f06 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

    TASK_DESC="S01: Create gradle job image for flex dataflow."
    COLOR="Not Started"
    case $s01 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

    TASK_DESC="S02: Run the 2nd dataflow job (Flex from gradle image)."
    COLOR="Not Started"
    case $s02 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style TASK_DESC COLOR

}
pushd ~/gcptest/techbash-ai/v2
if [ -d "triggers" ]
then
    rm -rf triggers/
fi

mkdir triggers
mkdir logs

sh i01.sh > logs/i01.log 2>&1 &
sh i02.sh > logs/i02.log 2>&1 &
sh f01.sh > logs/f01.log 2>&1 &
sh f02.sh > logs/f02.log 2>&1 &
sh f03.sh > logs/f03.log 2>&1 &
sh f04.sh > logs/f04.log 2>&1 &
sh f05.sh > logs/f05.log 2>&1 &
sh s01.sh > logs/s01.log 2>&1 &
sh s02.sh > logs/s02.log 2>&1 &

export PROJECT=$(gcloud config get-value project)

while :
do
    if [ -f "triggers/f04.f" ] && [ -f "triggers/f05.f" ]
    then
        read input
        if [ $input == "Y" ]
        then

            touch ~/gcptest/techbash-ai/v2/triggers/f08.f
        fi
    fi
    clear
    print_status
    sleep 2

done


