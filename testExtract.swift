import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string paraviewPath         = arg("pvpythonPath",
                                  "/home/marmar/programs-local/ParaView-5.3.0-Qt5-OpenGL2-MPI-Linux-64bit/bin/");
file utils[] 		        <filesys_mapper;location="utils", suffix=".py">;

string outDir              = "outputs/"; 


file extractScript          <"utils/extract.sh">;
file metrics2extract        <"inputs/boxKPI.csv">;

# ------ APP DEFINITIONS --------------------#


app (file MetricsOutput, file[] fpngs, file fOut, file ferr) extractMetrics (file extractScript,
																  string paraviewPath, file fsol,
																  file metrics2extract, string extractOutDir,
															      file utils[]){
    bash filename(extractScript) paraviewPath filename(fsol) filename(metrics2extract) extractOutDir
         filename(MetricsOutput) stderr=filename(ferr) stdout=filename(fOut);
}

#----------------workflow-------------------#

# Extract metrics and png files using paraview

int i=0;
string[] caseOutDirs;
caseOutDirs[i] = strcat(outDir, "case", i,"/");
string caseName = strcat(caseOutDirs[i], "solve");
file fsol         <strcat(caseName,".exo")>;

#foreach fsol, i in solFiles{
	file MetricsOutput  <strcat(caseOutDirs[i], "metrics.csv")>;
	string extractOutDir = strcat(outDir,"png/",i,"/");
	file fextractPng[]	 <filesys_mapper;location=extractOutDir>;	
	file fextractOut       <strcat(caseOutDirs[i], "extract.out")>;
	file fextractErr       <strcat(caseOutDirs[i], "extract.err")>;
	(MetricsOutput, fextractPng, fextractOut, fextractErr) = extractMetrics (extractScript, paraviewPath, fsol,
																			metrics2extract, extractOutDir, utils);
 # (MetricsOutput, fextractPng) =  extractMetricsTest (extractScript,  paraviewPath, fsol,
 # 									metrics2extract, extractOutDir, utils);
