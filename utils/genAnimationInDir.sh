#!/bin/bash

caseDir=$1
cd $caseDir

#dir=/core/

rm pngs -R > /dev/null 2>&1
mkdir -p pngs

timestep=0.1
simtime=0.5

timesteps=$(echo $simtime/$timestep | bc)
#timesteps=1

startDS=2 # specific to NDTEMP
numElements=4

maxDatasets=$(echo $numElements*$timesteps | bc)

element=1

frame=1

for ds in $(seq 2 $numElements $maxDatasets);do

echo $frame,$ds,$element



cat > tmp.fbd <<END
    read solve.frd new
    
    view bg k
    view fill
    view volu
    view disp
    view elem
    
    frame
    zoom 0.8
    rot y
    rot r 35
    rot u 35
    
    ds $ds e $element
    hcpy png
    sys mv hcpy_1.png pngs/$(printf "%04d\n" $frame).png
    
    exit
END

#xvfb-run -a --server-args="-screen 0 1024x768x24" $dir/cgx-212/cgx_2.12/src/cgx -b tmp.fbd > /dev/null # 2>&1
xvfb-run -a --server-args="-screen 0 1024x768x24" cgx_2.12 -b tmp.fbd > /dev/null # 2>&1
    
((frame++))
done

convert -delay 15 -loop 0 pngs/*.png temp.gif


#rm pngs -R
