import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string geomFileName = arg("geomFile", "box.step");
string meshFileName = arg("meshFile", "box_mesh");
string simParamsFileName = arg("simParamsFile", "boxSimFile");
string sweepParamsFileName = arg("sweepParamFile", "sweepParams.run");
string outDir = "outputs/";
string errorsDir = strcat(outDir, "errorFiles/");
string outCaseDir = "outputs/case";

file fgeom                <strcat("inputs/",geomFileName)>;
file fsweepParams		  <strcat("inputs/",sweepParamsFileName)>;

file meshScript           <"utils/boxMesh_inputFile.py">;
file utils[] 		      <filesys_mapper;location="utils">; #, suffix=".py">;
file convertScript        <"utils/unv2abaqus.py">;
file writeCGXScript       <"utils/writeCGXfbdFile.py">;

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

# Generate a CGX geometry command file
# python writeCGXfbdFile <cgxFile.fbd> <inputMeshFile> <outputMeshFile>
app (file fcgxFile, file ferr) writeCGXFile (file writeCGXScript, file fmeshInp, file utils[], string mshFileAddress){
    python filename(writeCGXScript) filename(fcgxFile) filename(fmeshInp) mshFileAddress stderr=filename(ferr);
}

#----------------workflow-------------------#

file caseFile 	<"inputs/cases.list">;
caseFile = expandSweep(fsweepParams, utils);

string simFilesDir = "inputs/simParamFiles/";
file[] simFileParams <filesys_mapper;location=simFilesDir>;
simFileParams = writeSimParamFiles(caseFile, utils, simFilesDir, simParamsFileName);

# Should I split into two loops? 
file[] fmeshes;
file[] fAbqMeshes;
foreach fsimParams,i in simFileParams{

   	file fmesh  	   <strcat(outDir, meshFileName,i,".unv")>;
    file salomeErr     <strcat(errorsDir, "salome",i,".err")>;                          
    (fmesh, salomeErr) = makeMesh(meshScript, fgeom, utils, fsimParams);
    fmeshes[i] = fmesh;

    string AbqMeshName = strcat(outDir, meshFileName,i);
    file fAbqMesh      <strcat(AbqMeshName, ".inp")>;
    file meshConvErr   <strcat(errorsDir, "meshConv", i, ".err")>;                          
    (fAbqMesh, meshConvErr) = convertMesh(convertScript, fmesh, utils, AbqMeshName);
    fAbqMeshes[i] = fAbqMesh;
}

file[] fcgxFiles;
foreach fAbqMesh,i in fAbqMeshes{
    file fcgxFile         <strcat(outCaseDir, i,"/premesh.fbd")>;
    file fcgxWriteErr     <strcat(outCaseDir, i,"/fcgxWriteErr.err")>;
    string mshFileAddress = strcat(outCaseDir, i, "/fcgxWriter.err");
    (fcgxFile, fcgxWriteErr) = writeCGXFile(writeCGXScript, fAbqMesh, utils, mshFileAddress);
    fcgxFiles[i] = fcgxFile;
}

