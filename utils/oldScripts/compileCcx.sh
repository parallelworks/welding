#!/bin/bash -e
CcxFolderName=$1 
BCFuncName=$2
extractDir=$3
tar -zxf ${CcxFolderName}.tar.gz   -C $extractDir
cp $BCFuncName ${CcxFolderName}/src/
cd  ${CcxFolderName}/src/         
make

