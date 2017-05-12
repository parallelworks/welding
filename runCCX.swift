import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#
string meshFileName = arg("meshFile", "box");

string ccxFolder = "utils/ccx-212";
file ccxBin                <strcat(ccxFolder,"/src/","ccx_2.12")>;
file ccxSrc                 <strcat(ccxFolder,".tar.gz")>; 
file ccxComplieScript       <"utils/compileCcx.sh">;
file getCcxInpScript        <"utils/writeCCXinpFile.py">;
file fgenericInp            <"inputs/solve.inp">;
file fluxRoutine            <"utils/dflux.f">;
file ccxExecScript          <"utils/runCcxBinary.sh">;
file utils[] 		      <filesys_mapper;location="utils", suffix=".py">;

# ------ APP DEFINITIONS --------------------#

app (file ccxBin) compileCcx (file complieScript, string ccxFolder, file ccxSrc, file fluxRoutine) {
    bash filename(complieScript) ccxFolder filename(fluxRoutine) "utils/" ;
}

app (file fccxInp) getCcxInp (file getCcxInpScript, file fgenericInp, file fmsh4ccx, file utils[]){
	python filename(getCcxInpScript) filename(fgenericInp) filename(fmsh4ccx) filename(fccxInp);
}

app (file fsol, file fsta, file fcvg, file fdat, file fOut, file ferr) runCcx (file ccxExecScript, file ccxBin, file fmsh4ccx, string caseName, file finp){
	bash filename(ccxExecScript) filename(ccxBin)  caseName stderr=filename(ferr) stdout=filename(fOut);
}

#----------------workflow-------------------#

int i = 1;
string outCaseDir = "outputs/case";

file fccxErr       <strcat(outCaseDir, i, "/ccx.err")>;
file fccxOut       <strcat(outCaseDir, i, "/ccx.out")>;
string caseName = strcat(outCaseDir, i,"/solve");

file fmsh4ccx     <strcat(outCaseDir, i, "/", meshFileName, ".msh")>;

file finp         <strcat(caseName,".inp")>;
file fsol         <strcat(caseName,".frd")>;
file fsta         <strcat(caseName,".sta")>;
file fcvg         <strcat(caseName,".cvg")>;
file fdat         <strcat(caseName,".dat")>;

ccxBin = compileCcx(ccxComplieScript, ccxFolder, ccxSrc, fluxRoutine);

finp = getCcxInp(getCcxInpScript, fgenericInp, fmsh4ccx, utils);

(fsol, fsta, fcvg, fdat, fccxOut, fccxErr) = runCcx(ccxExecScript, ccxBin, fmsh4ccx, caseName, finp);
