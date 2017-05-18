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

string ccxFolderRootName =  "ccx-212";
file ccxSrc                 <strcat("utils/", ccxFolderRootName, ".tar.gz")>; 
file compileScript          <"utils/compileCcx2.sh">;

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

app (file fanim, file[] fpngs, file fOut, file ferr) makeAnimation (file makeAnimScript, file fsol, string caseDir,
                                                                    file cgxBin){
	bash filename(makeAnimScript) caseDir stderr=filename(ferr) stdout=filename(fOut);
}

#----------------workflow-------------------#

file caseFile 	<"outputs/cases.list">;
caseFile = expandSweep(fsweepParams, utils);

string simFilesDir = "outputs/simParamFiles/";
file[] simFileParams <filesys_mapper;location=simFilesDir>;
simFileParams = writeSimParamFiles(caseFile, utils, simFilesDir, simParamsFileName);

file[] fmeshes;
file[] salPortFiles;
foreach fsimParams,i in simFileParams{
   	file fmesh  	   <strcat(outDir, meshFileName,i,".unv")>;
    file salomeErr     <strcat(errorsDir, "salome",i,".err")>;                          
    file salomeOut     <strcat(errorsDir, "salome",i,".out")>;                          
    file fsalPortNum   <strcat(outDir,"salomePort" ,i,".log")>;
    (fmesh, salomeErr, salomeOut, fsalPortNum) = makeMeshWritePort(runSalomeScript, meshScript, utils, fsimParams);
    fmeshes[i] = fmesh;
    salPortFiles[i] = fsalPortNum;
}

# Terminate Salome instances after done with generating all mesh files
foreach fsalPort,i in salPortFiles{
    file salKillErr     <strcat(errorsDir, "salomeKill",i,".err")>;                          
    file salKillOut     <strcat(errorsDir, "salomeKill",i,".out")>;                          
    (salKillErr, salKillOut) =  killSalomeInstance(killSalomeScript, fmeshes,  fsalPort);
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
string[] outCaseDirs;
foreach fAbqMesh,i in fAbqMeshes{
	outCaseDirs[i] = strcat(outCaseDir, i,"/");
    file ffbd              <strcat(outCaseDirs[i], "premesh.fbd")>;
    file fcgxWriteErr      <strcat(outCaseDirs[i], "fcgxWrite.err")>;
    mshFileAddresses[i] = strcat(outCaseDirs[i], meshFileName, ".msh");
    (ffbd, fcgxWriteErr) = writeFbdFile(writeFbdScript, fAbqMesh, utils, mshFileAddresses[i]);
    fbdFiles[i] = ffbd;
}

file[] fmsh4ccxFiles;
foreach ffbd,i in fbdFiles{
    file fmsh4ccx       <mshFileAddresses[i]>;
    file fOut           <strcat(outCaseDirs[i], "fcgxPremesh.out")>;
    file fcgxErr        <strcat(outCaseDirs[i], "fcgxPremesh.err")>;
    (fmsh4ccx, fOut, fcgxErr) = convertAbq2Msh(cgxExecScript, cgxBin, ffbd, fAbqMeshes[i]);
    fmsh4ccxFiles[i] = fmsh4ccx;
}

file[] ffluxRoutines;
foreach fsimParams,i in simFileParams{
   	file fluxRoutine 	   <strcat(outCaseDirs[i], "dflux.f")>;
    fluxRoutine =  writeFortranFluxRoutine(writeFortranFileScript, utils,  fsimParams);     
    ffluxRoutines[i] = fluxRoutine;
}

file[] ccxBinaries;
foreach fluxRoutine, i in ffluxRoutines{
        file ccxBin               <strcat(outCaseDirs[i], ccxFolderRootName, "/src/", "ccx_2.12")>;
        ccxBin = compileCcx(compileScript, outCaseDirs[i], ccxFolderRootName, ccxSrc, ffluxRoutines[i]);
        ccxBinaries[i] = ccxBin;
}

# Generate ccx input (.inp) files
file[] fCcxInpFiles;
foreach fmsh4ccx, i in fmsh4ccxFiles{
	string caseName = strcat(outCaseDirs[i], "solve");
	file finp       <strcat(caseName,".inp")>;
	finp = getCcxInp(getCcxInpScript, simFileParams[i], fmsh4ccx, utils);
	fCcxInpFiles[i] = finp;
}

# Run ccx for each case

file[] solFiles;
foreach fsimParams,i in simFileParams{
	string caseName = strcat(outCaseDirs[i], "solve");
	file fsol         <strcat(caseName,".frd")>;
	file fsta         <strcat(caseName,".sta")>;
	file fcvg         <strcat(caseName,".cvg")>;
	file fdat         <strcat(caseName,".dat")>;
	file fccxErr      <strcat(outCaseDirs[i], "ccx.err")>;
	file fccxOut      <strcat(outCaseDirs[i], "ccx.out")>;
	(fsol, fsta, fcvg, fdat, fccxOut, fccxErr) = 
		  runCcx(ccxExecScript, ccxBinaries[i], fmsh4ccxFiles[i], caseName, fCcxInpFiles[i]);
	solFiles[i] = fsol;
}

# Generate animation and png files for each case

foreach fsol, i in solFiles{

	file fanim          <strcat(outCaseDirs[i], "temp.gif")>;
	file[] fpngs        <filesys_mapper;location=strcat(outCaseDirs[i],"pngs")>;
	file fanimOut       <strcat(outCaseDirs[i], "anim.out")>;
	file fanimErr       <strcat(outCaseDirs[i], "anim.err")>;

	(fanim, fpngs, fanimOut, fanimErr) = makeAnimation(makeAnimScript, fsol, outCaseDirs[i], cgxBin);
}

