import "stdlib.v2";

type file;

string ccxFolderRootName =        "ccx-212";
file ccxSrc                <strcat("utils/", ccxFolderRootName, ".tar.gz")>; 
file compileScript     <"utils/compileCcx2.sh">;

app (file ccxBin) compileCcx (file compileScript, string outDir, string ccxTGZRootName, file ccxSrc, file fluxRoutine) {
    bash filename(compileScript) filename(ccxSrc) ccxTGZRootName filename(fluxRoutine) outDir;
}


int i = 1;
string[] outCaseDirs;
string outCaseDir = "outputs/case";
outCaseDirs[i] = strcat(outCaseDir, i,"/");
file ccxBin               <strcat(outCaseDirs[i],ccxFolderRootName, "/src/", "ccx_2.12")>;
file fluxRoutine 	   <strcat(outCaseDirs[i], "dflux.f")>;

trace(filename(fluxRoutine));

ccxBin = compileCcx(compileScript, outCaseDirs[i], ccxFolderRootName, ccxSrc, fluxRoutine);
