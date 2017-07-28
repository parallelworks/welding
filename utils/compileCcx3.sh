#!/bin/bash -e
writeFortranFileScript=$1
fsimParams=$2
extractDir=$3

BCFortranFile=$extractDir/dflux.f

python $writeFortranFileScript $BCFortranFile $fsimParams

tar -zxf utils/ccx-212-patch.tgz -C $extractDir
cp $BCFortranFile $extractDir/ccx-212-patch/src/


if [ "$embeddedDocker" = true ] ; then
    cd  $extractDir/ccx-212-patch/
    docker run --rm -i -v `pwd`:/scratch -w /scratch/src -u 0:0 avidalto/calculix:v11 make
else
cd  $extractDir/ccx-212-patch/src/
make
fi


