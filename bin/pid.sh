#!bin/bash

pid () 
{ 
    local prepend='';
    local append='';
    if [ "$1" = "--exact" ]; then
        prepend=' ';
        append='$';
        shift;
    fi;
    local EXE="$1";
    if [ "$EXE" ]; then
        local PID=`adb shell ps -A | tr -d '\r'             | \grep "$prepend$EXE$append"             | sed -e 's/^[^ ]* *\([0-9]*\).*$/\1/'`;
        echo "$PID";
    else
        echo "usage: pid [--exact] <process name>";
        return 255;
    fi
}

pid $@
