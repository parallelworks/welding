import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#
string meshFileName = arg("meshFile", "box");

string ccxFolder = "utils/ccx-212";
file ccxBin                 <strcat(ccxFolder,"/src/","ccx_2.12")>;
file ccxSrc                 <strcat(ccxFolder,".tar.gz")>; 
file ccxComplieScript       <"utils/compileCcx.sh">;
file getCcxInpScript        <"utils/writeCCXinpFile.py">;
file fgenericInp            <"inputs/solve.inp">;
file fluxRoutine            <"utils/dflux.f">;
file ccxExecScript          <"utils/runCcxBinary.sh">;
file utils[] 		        <filesys_mapper;location="utils", suffix=".py">;
file makeAnimScript         <"utils/genAnimationInDir.sh">;

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

app (file fanim, file[] fpngs, file fOut, file ferr) makeAnimation (file makeAnimScript, file fsol, string caseDir){
	bash filename(makeAnimScript) caseDir stderr=filename(ferr) stdout=filename(fOut);
}

#----------------workflow-------------------#

int i = 1;
string outCaseDir = strcat("outputs/case", i, "/");

file fccxErr       <strcat(outCaseDir, "ccx.err")>;
file fccxOut       <strcat(outCaseDir, "ccx.out")>;
string caseName = strcat(outCaseDir,"solve");

file fmsh4ccx     <strcat(outCaseDir, meshFileName, ".msh")>;

file finp         <strcat(caseName,".inp")>;
file fsol         <strcat(caseName,".frd")>;
file fsta         <strcat(caseName,".sta")>;
file fcvg         <strcat(caseName,".cvg")>;
file fdat         <strcat(caseName,".dat")>;

ccxBin = compileCcx(ccxComplieScript, ccxFolder, ccxSrc, fluxRoutine);

finp = getCcxInp(getCcxInpScript, fgenericInp, fmsh4ccx, utils);

(fsol, fsta, fcvg, fdat, fccxOut, fccxErr) = runCcx(ccxExecScript, ccxBin, fmsh4ccx, caseName, finp);


file fanim       <strcat(outCaseDir,"temp.gif")>;
file fanimOut       <strcat(outCaseDir,"anim.out")>;
file fanimErr       <strcat(outCaseDir,"anim.err")>;
file[] fpngs     <filesys_mapper;location=strcat(outCaseDir,"pngs")>;

(fanim, fpngs, fanimOut, fanimErr) = makeAnimation(makeAnimScript, fsol, outCaseDir);
