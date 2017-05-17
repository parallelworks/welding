import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string geomFileName = arg("geomFile", "box.step");
string meshFileName = arg("meshFile", "box");
string simParamsFileName = arg("simParamsFile", "boxSimFile");
string sweepParamsFileName = arg("sweepParamFile", "sweepParams.run");

string outDir = "outputs/";
string errorsDir = strcat(outDir, "errorFiles/");
string outCaseDir = "outputs/case";

file fgeom                <strcat("inputs/",geomFileName)>;
file fsweepParams		  <strcat("inputs/",sweepParamsFileName)>;

file meshScript           <"utils/makeHighResBoxWithMesh_inputFile.py">;
file runSalomeScript           <"utils/runSalome.sh">;
file killSalomeScript           <"utils/killSalome.sh">;
#file meshScript           <"utils/makeHighResBoxWithMesh_noArgs.py">;
#file meshScript           <"utils/boxMesh_inputFile.py">;

file utils[] 		      <filesys_mapper;location="utils", suffix=".py">;

file convertScript        <"utils/unv2abaqus.py">;

file writeFbdScript       <"utils/writeCGXfbdFile.py">;

file cgxBin                 <"utils/cgx_2.12">;
file cgxExecScript          <"utils/runCgxBinary.sh">;

file ccxBin               <strcat(ccxFolder,"/src/","ccx_2.12")>;
file ccxComplieScript     <"utils/compileCcx.sh">;
string ccxFolder =        "utils/ccx-212";
file ccxSrc                 <strcat(ccxFolder,".tar.gz")>; 
file fluxRoutine            <"utils/dflux.f">;

file getCcxInpScript        <"utils/writeCCXinpFile.py">;
file fgenericInp            <"inputs/solve.inp">;

file ccxExecScript          <"utils/runCcxBinary.sh">;

file makeAnimScript         <"utils/genAnimationInDir.sh">;

# ------ APP DEFINITIONS --------------------#

# Read parameters from the sweepParams file and write to cases file
app (file cases) expandSweep (file sweepParams, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
}

# Read the cases file and generate a simFileParams file for each case
app (file[] simFileParams) writeSimParamFiles (file cases, file[] utils, string simFilesDir, string simFileRootName) {
	python "utils/writeSimParamFiles.py" filename(cases) simFilesDir simFileRootName;
}

#
# Generate mesh by running a Salome Python script
# Example of running Python mesh script by Salome :
#    salome start -t -w 1 boxMesh_inputFile.py args:inputs/geomMeshParams.in,inputs/box.step,outputs/box_mesh.unv 
#
app (file fmesh, file ferr) makeMeshFromStep (file meshScript, file fgeom, file utils[], file fsimParams ) {
    salome "start" "-t" "-w 1" filename(meshScript) stderr=filename(ferr) strcat("args:",
           filename(fsimParams), ",", filename(fgeom), ",", filename(fmesh));
}

app (file fmesh, file ferr) makeMesh (file meshScript, file utils[], file fsimParams ) {
    salome "start" "-t" "-w 1" filename(meshScript) stderr=filename(ferr) strcat("args:",
           filename(fsimParams), ",", filename(fmesh));
}

app (file fmesh, file ferr) makeMeshNoArgs (file meshScript) {
    salome "start" "-t" "-w 1" filename(meshScript) stderr=filename(ferr);
}

app (file fmesh, file ferr, file fout, file salPort) makeMeshWritePort (file runSalomeScript, file meshScript, file utils[], file fsimParams) {
    bash filename(runSalomeScript) filename(salPort) filename(meshScript) filename(fsimParams) filename(fmesh) stderr=filename(ferr) stdout=filename(fout);
}

app (file ferr, file fout) killSalomeInstance (file killSalomeScript, file[] fmeshes,  file salPort){
    bash filename(killSalomeScript) filename(salPort) stderr=filename(ferr) stdout=filename(fout); 
}

#----------------workflow-------------------#

file caseFile 	<"inputs/cases.list">;
caseFile = expandSweep(fsweepParams, utils);

string simFilesDir = "inputs/simParamFiles/";
file[] simFileParams <filesys_mapper;location=simFilesDir>;
simFileParams = writeSimParamFiles(caseFile, utils, simFilesDir, simParamsFileName);

# int i = 0;
# file salomeErr     <strcat(errorsDir, "salome",i,".err")>;                          
# file fmesh <strcat(outDir, meshFileName,i,".unv")>;
# (fmesh, salomeErr) = makeMeshNoArgs(meshScript);        

file[] fmeshes;
file[] salPortFiles;
foreach fsimParams,i in simFileParams{
   	file fmesh  	   <strcat(outDir, meshFileName,i,".unv")>;
    file salomeErr     <strcat(errorsDir, "salome",i,".err")>;                          
    file salOut     <strcat(errorsDir, "salome",i,".out")>;                          
    file fsalPortNum   <strcat("salomePort" ,i,".log")>;
    (fmesh, salomeErr, salOut, fsalPortNum) = makeMeshWritePort(runSalomeScript, meshScript, utils, fsimParams);
#    (fmesh, salomeErr) = makeMeshFromStep(meshScript, fgeom, utils, fsimParams);
    fmeshes[i] = fmesh;
    salPortFiles[i] = fsalPortNum;
}

# Terminate Salome instances after done with generating all mesh files
foreach fsalPort,i in salPortFiles{
    file salKillErr     <strcat(errorsDir, "salomeKill",i,".err")>;                          
    file salKillOut     <strcat(errorsDir, "salomeKill",i,".out")>;                          
    (salKillErr, salKillOut) =  killSalomeInstance(killSalomeScript, fmeshes,  fsalPort);
}
