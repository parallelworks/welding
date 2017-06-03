#!/bin/bash 
WORK_DIR=$(pwd)
portlogFile=$1 
#salomePath=$2

# This is from Salome documentation:

## Handling concurrent starts
#  Each SALOME application owns a specific port number. This port is determined automatically when application
#  starts. When multiple applications are started at the same time, assigning a number to each port could be 
#  conflicting, and the same port could be assigned to several applications. To prevent from such a situation, 
#  a Python object named Portmanager has been implemented. This object has been introduced in SALOME 7 as an
#  optional tool, then evaluated on Linux and Windows. In SALOME 8, this object becomes the standard.

export PATH=$PATH:$SALOMEPATH

salome kill `cat ${WORK_DIR}/$portlogFile`

