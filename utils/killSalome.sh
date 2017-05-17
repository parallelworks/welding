#!/bin/bash 
WORK_DIR=$(pwd)
portlogFile=$1 
salome kill `cat ${WORK_DIR}/$portlogFile`

