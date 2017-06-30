import "stdlib.v2";

type file;


app (file fout) testEnv (string dirName, file script ){
    bash filename(script) dirName;
}

string dirName = "testDir";
file fout      <strcat(dirName,"/test.txt")>;
file script    <"utils/testEnv.sh">;
fout = testEnv(dirName, script);
