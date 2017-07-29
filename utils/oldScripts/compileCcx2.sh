#!/bin/bash -e
CCxTarFile=$1
CcxFolderName=$2
BCFuncName=$3
extractDir=$4
tar -zxf $CCxTarFile   -C $extractDir
cp $BCFuncName $extractDir/${CcxFolderName}/src/
cd  $extractDir/${CcxFolderName}/src/         
make
