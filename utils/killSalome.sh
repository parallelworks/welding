#!/bin/bash 
WORK_DIR=$(pwd)
portlogFile=$1 
#salomePath=$2

export PATH=$PATH:$SALOMEPATH

salome kill `cat ${WORK_DIR}/$portlogFile`

