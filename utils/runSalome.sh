#!/bin/bash 
WORK_DIR=$(pwd)
salomePath=$1
portlogFile=$2 
meshScript=$3
fsimParams=$4
fmesh=$5

export PATH=$PATH:$salomePath

salome start -t   --ns-port-log=${WORK_DIR}/$portlogFile 
salome shell -p `cat ${WORK_DIR}/$portlogFile`  $meshScript args:$fsimParams,$fmesh 


