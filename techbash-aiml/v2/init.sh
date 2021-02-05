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

    if [ -f "$SRC_DIR/triggers/i01.s" ]
    then
        i01=1
    fi
    if [ -f "$SRC_DIR/triggers/i01.f" ]
    then
        i01=2
    fi

    if [ -f "$SRC_DIR/triggers/i02.s" ]
    then
        i02=1
    fi
    if [ -f "$SRC_DIR/triggers/i02.f" ]
    then
        i02=2
    fi

    if [ -f "$SRC_DIR/triggers/f01.s" ]
    then
        f01=1
    fi
    if [ -f "$SRC_DIR/triggers/f01.f" ]
    then
        f01=2
    fi

    if [ -f "$SRC_DIR/triggers/f02.s" ]
    then
        f02=1
    fi
    if [ -f "$SRC_DIR/triggers/f02.f" ]
    then
        f02=2
    fi

    if [ -f "$SRC_DIR/triggers/f03.s" ]
    then
        f03=1
    fi
    if [ -f "$SRC_DIR/triggers/f03.f" ]
    then
        f03=2
    fi

    if [ -f "$SRC_DIR/triggers/f04.s" ]
    then
        f04=1
    fi
    if [ -f "$SRC_DIR/triggers/f04.f" ]
    then
        f04=2
    fi

    if [ -f "$SRC_DIR/triggers/f05.s" ]
    then
        f05=1
    fi
    if [ -f "$SRC_DIR/triggers/f05.f" ]
    then
        f05=2
    fi

    if [ -f "$SRC_DIR/triggers/f06.s" ]
    then
        f06=1
    fi
    if [ -f "$SRC_DIR/triggers/f06.f" ]
    then
        f06=2
    fi

    if [ -f "$SRC_DIR/triggers/s01.s" ]
    then
        s01=1
    fi
    if [ -f "$SRC_DIR/triggers/s01.f" ]
    then
        s01=2
    fi

    if [ -f "$SRC_DIR/triggers/s02.s" ]
    then
        s02=1
    fi
    if [ -f "$SRC_DIR/triggers/s02.f" ]
    then
        s02=2
    fi
}
print_status() {

    get_status

    TASK_DESC="I01:_Get_tar_file_and_extract.\n"
    COLOR="Not Started"
    case $i01 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR
    
    TASK_DESC="I02:_Git_Cloned.\n"
    COLOR="Not Started"
    case $i02 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

    TASK_DESC="F01:_Create_pubsub_topics_and_buckets.\n"
    COLOR="Not Started"
    case $f01 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

    TASK_DESC="F02:_Create_BQ_tables_and_query_them.\n"
    COLOR="Not Started"
    case $f02 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

    TASK_DESC="F03:_Cloud_run_build_and_submit.\n"
    COLOR="Not Started"
    case $f03 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

    TASK_DESC="F04:_Run_dataflow_job.\n"
    COLOR="Not Started"
    case $f04 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

    TASK_DESC="F05:_POST_ecommerce_files_to_cloudrun_endpoint.\n"
    COLOR="Not Started"
    case $f05 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

    TASK_DESC="F06:_User_input.\n"
    COLOR="Not Started"
    case $f06 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

    TASK_DESC="S01:_Create_gradle_job_image_for_flex_dataflow.\n"
    COLOR="Not Started"
    case $s01 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

    TASK_DESC="S02:_Run_the_2nd_dataflow_job_(Flex_from_gradle_image).\n"
    COLOR="Not Started"
    case $s02 in
        1)
        COLOR="warning"
        ;;
        2)
        COLOR="success"
    esac
    print_style $TASK_DESC $COLOR

}

export SRC_DIR="$HOME/gcptest/techbash-aiml/v2"
export PROJECT=$(gcloud config get-value project)

if [ -d "triggers" ]
then
    rm -rf $SRC_DIR/triggers/
fi

mkdir $SRC_DIR/triggers
mkdir $SRC_DIR/logs

sh $SRC_DIR/i01.sh > $SRC_DIR/logs/i01.log 2>&1 &
sh $SRC_DIR/i02.sh > $SRC_DIR/logs/i02.log 2>&1 &
sh $SRC_DIR/f01.sh > $SRC_DIR/logs/f01.log 2>&1 &
sh $SRC_DIR/f02.sh > $SRC_DIR/logs/f02.log 2>&1 &
sh $SRC_DIR/f03.sh > $SRC_DIR/logs/f03.log 2>&1 &
sh $SRC_DIR/f04.sh > $SRC_DIR/logs/f04.log 2>&1 &
sh $SRC_DIR/f05.sh > $SRC_DIR/logs/f05.log 2>&1 &
sh $SRC_DIR/s01.sh > $SRC_DIR/logs/s01.log 2>&1 &
sh $SRC_DIR/s02.sh > $SRC_DIR/logs/s02.log 2>&1 &

while :
do
    if [ -f "$SRC_DIR/triggers/f04.f" ] && [ -f "$SRC_DIR/triggers/f05.f" ]
    then
        if [ !-f $SRC_DIR/"triggers/f06.f" ]
        then
            printf "Please select Y/n: "
            read input
            if [ $input == "Y" ]
            then

                touch $SRC_DIR/triggers/f06.f
            fi
        fi
    fi
    clear
    print_status
    sleep 2

done


