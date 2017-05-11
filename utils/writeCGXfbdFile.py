import sys
import data_IO

# Input arguments:

if len(sys.argv) < 4:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python writeCGXfbdFile <cgxFile.fbd> <inputMeshFile> <outputMeshFile>")
    sys.exit()

cgxFile = sys.argv[1]
inputMeshFile = sys.argv[2]
outputMeshFile = sys.argv[3]

'''
Sample fbc file reading mesh file box_mesh1.inp and writing results into test.msh:

 read box_mesh1.inp
 zap STRI35
 send all abq
 sys mv all.msh test.msh
 
'''

fCgx = data_IO.open_file(cgxFile, "w")
fCgx.write("read " + inputMeshFile + "\n")
fCgx.write("zap STRI35\n")
fCgx.write("send all abq\n")
fCgx.write("sys mv all.msh " + outputMeshFile + "\n")
fCgx.close()
