import "stdlib.v2";

type file;
file utils[] 		        <filesys_mapper;location="utils/", pattern="*.*">;
#file utils[] 		        <filesys_mapper;location="utils/", suffix=".sh">;

app (file fout) testEnv (string dirName, file utils[]){
    bash "utils/testEnv.sh" dirName;
    bash "utils/testEnvAppend.sh" dirName;
}

string dirName = "testDir";
file fout      <strcat(dirName,"/test.txt")>;
file script    <"utils/testEnv.sh">;
fout = testEnv(dirName, utils);
