#!/bin/bash

# Input
outputFolder=$1 # Path to the folder containing all the outputs
outputTar=$2 # Path to the compressed file
# Zip results
#cp -r outputs $outputFolder
tar -czvf $outputTar $outputFolder
