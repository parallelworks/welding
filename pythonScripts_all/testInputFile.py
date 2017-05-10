
import sys
import data_IO

# Input arguments: 

if len(sys.argv) < 3:
    print("Number of provided arguments: ", len(sys.argv) -1 )
    print( "Usage: python boxMesh <inputFile.in> <geomFile.step>")
    print( "       [<meshFileName=box_mesh.unv>")
    sys.exit()


inputFileName = sys.argv[1]
geomFileAddress = sys.argv[2]

if len(sys.argv) >= 3:
    meshFileName = sys.argv[3]
else:
    meshFileName = "outputs/box_mesh.unv"

# Read parameters from input file
in_fp = data_IO.open_file(inputFileName)
Length = data_IO.read_float_from_file_pointer(in_fp, "Length")
Height = data_IO.read_float_from_file_pointer(in_fp, "Height")
Width = data_IO.read_float_from_file_pointer(in_fp, "Width")
highResWidth = data_IO.read_float_from_file_pointer(in_fp, "highResWidth")
meshScale = data_IO.read_float_from_file_pointer(in_fp, "meshScale")
in_fp.close()

Length2 = 10.0
print(Length, Height, Width, highResWidth, meshScale)
