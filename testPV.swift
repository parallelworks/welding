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

file fgeom                  <strcat("inputs/",geomFileName)>;
file fsweepParams		    <strcat("inputs/",sweepParamsFileName)>;

file runSalomeScript        <"utils/runSalome.sh">;
file killSalomeScript       <"utils/killSalome.sh">;
file meshScript             <"utils/makeHighResBoxWithMesh_inputFile.py">;

file utils[] 		        <filesys_mapper;location="utils", suffix=".py">;

file convertScript          <"utils/unv2abaqus.py">;

file writeFbdScript         <"utils/writeCGXfbdFile.py">;

file cgxBin                 <"utils/cgx_2.12">;
file cgxExecScript          <"utils/runCgxBinary.sh">;

file writeFortranFileScript <"utils/writeDFluxFile.py">;

string ccxFolderRootName =  "ccx-212-patch";
file ccxSrc                 <strcat("utils/", ccxFolderRootName, ".tar.gz")>; 
file compileScript          <"utils/compileCcx2.sh">;

file getCcxInpScript        <"utils/writeCCXinpFile.py">;
file fgenericInp            <"inputs/solve.inp">;

file ccxExecScript          <"utils/runCcx2PVBinary.sh">;

file makeAnimScriptCgx      <"utils/genAnimationInDir.sh">;
file makeAnimScriptPV       <"utils/genAnimationPV.sh">;
file paraviewPythonScript   <"utils/pvLoadSavePngs.py">;

# ------ APP DEFINITIONS --------------------#

# Read parameters from the sweepParams file and write to cases file
app (file cases) expandSweep (file sweepParams, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
}

# Read the cases file and generate a simFileParams file for each case
app (file[] simFileParams) writeSimParamFiles (file cases, file[] utils, string simFilesDir, 
                                                                         string simFileRootName) {
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

app (file fmesh, file ferr, file salPort) makeMesh (file meshScript, file utils[], file fsimParams ) {
    salome "start" "-t" "-w 1"  "--ns-port-log="filename(salPort) filename(meshScript) 
           stderr=filename(ferr) strcat("args:", filename(fsimParams), ",", filename(fmesh));
}

app (file fmesh, file ferr, file fout, file salPort) makeMeshWritePort (file runSalomeScript, file meshScript,
                                                                        file utils[], file fsimParams) {
    bash filename(runSalomeScript) filename(salPort) filename(meshScript) filename(fsimParams) filename(fmesh) 
         stderr=filename(ferr) stdout=filename(fout);
}

app (file ferr, file fout) killSalomeInstance (file killSalomeScript, file[] fmeshes,  file salPort){
    bash filename(killSalomeScript) filename(salPort) stderr=filename(ferr) stdout=filename(fout); 
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
app (file fmsh4ccx, file fOut, file ferr) convertAbq2Msh (file cgxExecScript, file cgxBin, 
                                                          file ffbd, file fmeshInp){
	bash filename(cgxExecScript) filename(cgxBin) filename(ffbd) stderr = filename(ferr) stdout = filename(fOut);
}

#write fortran flux files
#python pythonScripts_all/writeDFluxFile.py dfluxTest.f inputs/simParamFiles/boxSimFile0.in
app (file fluxRoutine) writeFortranFluxRoutine (file writeFortranFileScript, file utils[], file fsimParams){
    python filename(writeFortranFileScript) filename(fluxRoutine) filename(fsimParams);
}

app (file ccxBin) compileCcx (file compileScript, string outDir, string ccxTGZRootName, file ccxSrc,
                              file fluxRoutine) {
    bash filename(compileScript) filename(ccxSrc) ccxTGZRootName filename(fluxRoutine) outDir;
}

app (file fccxInp) getCcxInp (file getCcxInpScript, file fsimParams, file fmsh4ccx, file utils[]){
	python filename(getCcxInpScript) filename(fsimParams) filename(fmsh4ccx) filename(fccxInp);
}

app (file fsol, file fsta, file fcvg, file fdat, file fOut, file ferr) 
	runCcx (file ccxExecScript, file ccxBin, file fmsh4ccx, string caseName, file finp){
	bash filename(ccxExecScript) filename(ccxBin)  caseName stderr=filename(ferr) stdout=filename(fOut);
}

app (file fanim, file[] fpngs, file fOut, file ferr) makeAnimationCgx (file makeAnimScriptCgx, file fsol, string caseDir,
                                                                    file cgxBin){
	bash filename(makeAnimScriptCgx) caseDir stderr=filename(ferr) stdout=filename(fOut);
}

app (file fanim, file[] fpngs, file fOut, file ferr) makeAnimationPV (file makeAnimScriptPV, 
                                                                      file paraviewPythonScript, file fsol, 
                                                                      string pngDir){
    bash filename(makeAnimScriptPV) filename(paraviewPythonScript) filename(fsol) pngDir filename(fanim)
         stderr=filename(ferr) stdout=filename(fOut);
}

#----------------workflow-------------------#


# Generate animation and png files for each case
int ii = 0;
string[] outCaseDirs;

outCaseDirs[ii] = strcat(outCaseDir, ii,"/");
string caseName = strcat(outCaseDirs[ii], "solve");

file[] solFiles;
file fsoli         <strcat(caseName,".exo")>;
solFiles[ii] = fsoli;

foreach fsol, i in solFiles{

	file fanim          <strcat(outCaseDirs[i], "temp.gif")>;
	string pngDir =     strcat(outCaseDirs[i],"pngs");
	file[] fpngs        <filesys_mapper;location=pngDir>;
	file fanimOut       <strcat(outCaseDirs[i], "anim.out")>;
	file fanimErr       <strcat(outCaseDirs[i], "anim.err")>;
	(fanim, fpngs, fanimOut, fanimErr) = makeAnimationPV(makeAnimScriptPV, paraviewPythonScript, fsol, pngDir);
}

