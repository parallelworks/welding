import sys
import data_IO

# Input arguments:

if len(sys.argv) < 4:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python writeCCXinpFile <genericInputFile> <inputMeshFile> <caseInputFile>")
    sys.exit()

genericInputFile = sys.argv[1]
inputMeshFile = sys.argv[2]
caseInputFile = sys.argv[3]


fgInput = data_IO.open_file(genericInputFile, "r")
fInputCase = data_IO.open_file(caseInputFile, "w")

lines = fgInput.readlines()
lines[0] = '*include, input='+inputMeshFile+'\n'
fInputCase.writelines(lines)
fgInput.close()
fInputCase.close()
