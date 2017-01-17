#!/bin/bash -f
 
ARCHITECTURE=$(uname -m)
 
if [ "${ARCHITECTURE}" = "x86_64" ]; 
    then
        ARCHITECTURE_SHORT_NAME=x86
    else
        ARCHITECTURE_SHORT_NAME=rpi
fi
 
echo ${ARCHITECTURE_SHORT_NAME}
