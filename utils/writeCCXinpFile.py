import sys
import data_IO

# Input arguments:

if len(sys.argv) < 4:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python writeCCXinpFile <simParams.in> <inputMeshFile> <caseInputFile.inp>")
    sys.exit()


simParamsAddress = sys.argv[1]
inputMeshFile = sys.argv[2]
caseInputFile = sys.argv[3]

# Read parameters from input file
fInput = data_IO.open_file(simParamsAddress, "r")

dt = data_IO.read_float_from_file_pointer(fInput, "sim_dt")
TotalTime = data_IO.read_float_from_file_pointer(fInput, "sim_totalTime")

fInput.close()

fInputCase = data_IO.open_file(caseInputFile, "w")

fInputCase.write('*include, input='+inputMeshFile+'\n')
fInputCase.write(' \n'
                 '** material definition \n'
                 '*material, name=steel \n'
                 '*elastic \n'
                 '210000,0.333333333,0 \n'
                 '*density \n'
                 '7.85e-9 \n'
                 '*expansion \n'
                 '12e-6 \n'
                 '*conductivity \n'
                 '50.,0 \n'
                 '*specific heat \n'
                 '5e8,0 \n'
                 ' \n'
                 '** material assignment to bodies \n'
                 '*solid section, elset=Eall, material=steel \n'
                 ' \n'
                 '** initial temperature \n'
                 '*initial conditions, type=temperature \n'
                 'Nall,25 \n'
                 ' \n'
                 '*step \n'
                 ' \n'
                 '*COUPLED TEMPERATURE-DISPLACEMENT,DIRECT \n')

fInputCase.write(str(dt) + ',' + str(TotalTime) + '\n')

fInputCase.write('\n'
                 '*dflux,OP=NEW \n'
                 'Eall,BFNU,1. \n'
                 ' \n'
                 '*node file \n'
                 'NT,U \n'
                 '*el file \n'
                 'S,HFL \n'
                 ' \n'
                 '*end step \n')

fInputCase.close()
