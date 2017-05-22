#!/bin/bash 
WORK_DIR=$(pwd)
portlogFile=$1 
salomePath=$2

export PATH=$PATH:$salomePath

salome kill `cat ${WORK_DIR}/$portlogFile`

