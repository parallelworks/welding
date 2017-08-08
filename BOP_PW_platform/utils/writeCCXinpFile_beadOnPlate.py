import sys
import data_IO

# Input arguments:

if len(sys.argv) < 3:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python writeCCXinpFile <simParams.in> <ccxInputFile.inp>")
    sys.exit()

simParamsAddress = sys.argv[1]
ccxInputFile = sys.argv[2]

# Read parameters from input file
fsimParams = data_IO.open_file(simParamsAddress, "r")

dt = data_IO.read_float_from_file_pointer(fsimParams, "sim_dt")
TotalTime = data_IO.read_float_from_file_pointer(fsimParams, "sim_totalTime")
Temp0 = data_IO.read_float_from_file_pointer(fsimParams, "Temp0")
fsimParams.close()

fCcxInput = data_IO.open_file(ccxInputFile, "w")

fCcxInput.write('*include, input=allinone.inp  \n'
                '** material definition  \n'
                '*include, input=materialLib.mat  \n')
fCcxInput.write('*solid section, elset=EbeadSolid, material=x6  \n')
fCcxInput.write('*solid section, elset=EplateSolid, material=steel2  \n')
fCcxInput.write('*initial conditions, type=temperature  \n')
fCcxInput.write('Nall,' + str(Temp0) + '\n')
fCcxInput.write('  \n'
                '*TIME POINTS,NAME=T1,GENERATE \n')
fCcxInput.write('0.0,' + str(TotalTime) + ',' + str(dt) + '\n')
fCcxInput.write('  \n'
                '*step,INC=500  \n'
                '*UNCOUPLED TEMPERATURE-DISPLACEMENT \n')
fCcxInput.write(str(dt) + ',' + str(TotalTime) + '\n')
fCcxInput.write('  \n'
                '*dflux,OP=NEW  \n'
                'Eall,BFNU,1.  \n'
                '  \n'
                '*node file,TIMEPOINTS=T1  \n'
                'NT,U  \n'
                '*el file,TIMEPOINTS=T1   \n'
                'S,HFL  \n'
                '*end step  \n'
                ' \n')

fCcxInput.close()
