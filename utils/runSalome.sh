#!/bin/bash 
WORK_DIR=$(pwd)
portlogFile=$1
meshScript=$2
fsimParams=$3
fmesh=$4

export PATH=$PATH:$SALOMEPATH

salome start -t   --ns-port-log=${WORK_DIR}/$portlogFile 
salome shell -p `cat ${WORK_DIR}/$portlogFile`  $meshScript args:$fsimParams,$fmesh 


