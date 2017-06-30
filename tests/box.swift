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

file meshScript           <"utils/boxMesh_inputFile.py">;
file utils[] 		      <filesys_mapper;location="utils", suffix=".py">;
file convertScript        <"utils/unv2abaqus.py">;
file writeFbdScript       <"utils/writeCGXfbdFile.py">;

file cgxBin                 <"utils/cgx_2.12">;
file cgxExecScript          <"utils/runCgxBinary.sh">;

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
app (file fmesh, file ferr) makeMesh (file meshScript, file fgeom, file utils[], file fsimParams ) {
    salome "start" "-t" "-w 1" filename(meshScript) stderr=filename(ferr) strcat("args:",
           filename(fsimParams), ",", filename(fgeom), ",", filename(fmesh));
}

(string nameNoSuffix) trimSuffix (string nameWithSuffix){
   int suffixStartLoc = lastIndexOf(nameWithSuffix, ".", -1);
   nameNoSuffix = substring(nameWithSuffix, 0, suffixStartLoc); 
}

# Convert the mesh to abaqus format
app (file fmeshInp, file ferr) convertMesh (file convertScript, file fmesh, file utils[], string meshInpName){
    python2 filename(convertScript) filename(fmesh) meshInpName stderr=filename(ferr);
} 

# Generate a cgx geometry command (fbd) file
# python writeCGXfbdFile <cgxFile.fbd> <inputMeshFile> <outputMeshFile>
app (file ffbd, file ferr) writeFbdFile (file writeFbdScript, file fmeshInp, file utils[], string mshFileAddress){
    python filename(writeFbdScript) filename(ffbd) filename(fmeshInp) mshFileAddress stderr=filename(ferr);
}

# convert abq mesh to ccx 
#cgx -bg prepmesh.fbd
app (file fmsh4ccx, file fOut, file ferr) convertAbq2Msh (file cgxExecScript, file cgxBin, file ffbd, file fmeshInp){
#    "cgx_2.12" "-bg" filename(ffbd) stderr=filename(ferr) stdout= filename(fOut);
	bash filename(cgxExecScript) filename(cgxBin) filename(ffbd) stderr = filename(ferr) stdout = filename(fOut);
}


#----------------workflow-------------------#

file caseFile 	<"inputs/cases.list">;
caseFile = expandSweep(fsweepParams, utils);

string simFilesDir = "inputs/simParamFiles/";
file[] simFileParams <filesys_mapper;location=simFilesDir>;
simFileParams = writeSimParamFiles(caseFile, utils, simFilesDir, simParamsFileName);

file[] fmeshes;
foreach fsimParams,i in simFileParams{
   	file fmesh  	   <strcat(outDir, meshFileName,i,".unv")>;
    file salomeErr     <strcat(errorsDir, "salome",i,".err")>;                          
    (fmesh, salomeErr) = makeMesh(meshScript, fgeom, utils, fsimParams);
    fmeshes[i] = fmesh;
}

file[] fAbqMeshes;
foreach fmesh,i in fmeshes{
    string AbqMeshName = strcat(outDir, meshFileName,i);
    file fAbqMesh      <strcat(AbqMeshName, ".inp")>;
    file meshConvErr   <strcat(errorsDir, "meshConv", i, ".err")>;                          
    (fAbqMesh, meshConvErr) = convertMesh(convertScript, fmesh, utils, AbqMeshName);
    fAbqMeshes[i] = fAbqMesh;
}

file[] fbdFiles;
string[] mshFileAddresses;
foreach fAbqMesh,i in fAbqMeshes{
    file ffbd              <strcat(outCaseDir, i,"/premesh.fbd")>;
    file fcgxWriteErr      <strcat(outCaseDir, i,"/fcgxWrite.err")>;
     mshFileAddresses[i] = strcat(outCaseDir, i, "/", meshFileName, ".msh");
    (ffbd, fcgxWriteErr) = writeFbdFile(writeFbdScript, fAbqMesh, utils, mshFileAddresses[i]);
    fbdFiles[i] = ffbd;
}

file[] fmsh4ccxFiles;
foreach ffbd,i in fbdFiles{
    file fmsh4ccx <mshFileAddresses[i]>;
    file fOut           <strcat(outCaseDir, i,"/fcgxPremesh.out")>;
    file fcgxErr        <strcat(outCaseDir, i,"/fcgxPremesh.err")>;
    (fmsh4ccx, fOut, fcgxErr) = convertAbq2Msh(cgxExecScript, cgxBin, ffbd, fAbqMeshes[i]);
    fmsh4ccxFiles[i] = fmsh4ccx;
}

