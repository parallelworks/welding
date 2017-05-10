# python "utils/writeSimParamFiles.py"  filename(cases)  inputDir simFileRootName;

import sys
import data_IO

# Input arguments:

if len(sys.argv) < 4:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python writeSimParamFiles <cases.list> <inputDir> <simFileRootName>")
    sys.exit()


caseListFileName = sys.argv[1]
inputDir = sys.argv[2]
simFileRootName = sys.argv[3]


cl_fp = data_IO.open_file(caseListFileName)
for i, line in enumerate(cl_fp, 1):
    line = line.replace(",", "\n")
    line = line.replace("=", "  ")
    simFileAddress = inputDir + "/" + simFileRootName + str(i) + ".in"
    simf = data_IO.open_file(simFileAddress, "w")
    simf.write(line)
    simf.close()

cl_fp.close()
