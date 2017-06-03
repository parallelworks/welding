#!/bin/bash -e
writeFortranFileScript=$1
fsimParams=$2
extractDir=$3

BCFortranFile=$extractDir/dflux.f

python $writeFortranFileScript $BCFortranFile $fsimParams

tar -zxf utils/ccx-212-patch.tgz -C $extractDir
cp $BCFortranFile $extractDir/ccx-212-patch/src/
cd  $extractDir/ccx-212-patch/src/
make
