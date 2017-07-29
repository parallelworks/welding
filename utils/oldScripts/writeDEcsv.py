import sys
import math
import itertools as it
import data_IO

def isInt(s):
    try:
        int(s)
        return True
    except ValueError:
        return False


def frange(a, b, inc):
    if isInt(a) and isInt(b) and isInt(inc):
        a = int(a)
        b = int(b)
        inc = int(inc)
    else:
        a = float(a)
        b = float(b)
        inc = float(inc)
    x = [a]
    for i in range(1, int(math.ceil(((b + inc) - a) / inc))):
        x.append(a + i * inc)
    return (str(e) for e in x)


def expandVars(v):
    min = v.split(":")[0]
    max = v.split(":")[1]
    step = v.split(":")[2]
    v = ','.join(frange(min, max, step))
    return v


def genOutputLookupTable(outParamsList):
    lookupTable = []
    stat2numTable = {'ave': 0, 'min': 1, 'max': 2}
    for param in outParamsList:
        paramName = param[:param.find("(")]
        paramName = paramName.lstrip()
        statStr = param[param.find("(")+1:param.find(")")]
        statKey = stat2numTable[statStr]
        lookupTable.append([paramName, statKey])
    return lookupTable


if len(sys.argv) < 6:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python2 writeDEcsv.py <sweepParams.run> <outputParams.txt> <DesignExplorer.csv> <extractedFileName>"
          " <resultsDirRootName>")
    print("[writeSingleValuedOutputs=True]")
    sys.exit()


inputParamsFileAddress = sys.argv[1]
outputParamsFileAddress = sys.argv[2]
outcsvFileAddress = sys.argv[3]
extractedFileName = sys.argv[4]
resultsDirRootName = sys.argv[5]

if len(sys.argv) >= 7:
    writeSingleValueInputs = data_IO.str2bool(sys.argv[6])
else:
    writeSingleValueInputs = True


with open(inputParamsFileAddress) as f:
    content = f.read().splitlines()

pvals = {}
for x in content:
    if "null" not in x and x != "":
        pname = x.split(";")[0]
        pval = x.split(";")[1]
        if " " in pval:
            pval = pval.split(" ")
        elif ":" in pval:
            pval = expandVars(pval).split(",")
        else:
            # Ignore single value input parameters
            if writeSingleValueInputs:
                pval = [pval]
            else:
                continue
        pvals[pname] = pval

varNames = sorted(pvals)
cases = [[{varName: val} for varName, val in zip(varNames, prod)] for prod in
         it.product(*(pvals[varName] for varName in varNames))]

print("Generated " + str(len(cases)) + " Cases")


# Set the header for the inputs
header = []
for varName in varNames:
    header +="in:"+varName+","
header = "".join(header[:-1])

# Add the values of input parameters for each case to caselist
caselist = []
for c in cases:
    case = ""
    for p in c:
        pname = p.keys()[0]
        pval = p[pname]
        case += pval + ","
    caselist.append(case[:-1])

# Read the desired output metrics
with open(outputParamsFileAddress) as foutParams:
    outParamsList = foutParams.read().splitlines()[0]
    outParamsList = outParamsList.split(',')

paramTable = genOutputLookupTable(outParamsList)

# Add outputs to the header
for param in paramTable:
    header += ",out:" + param[0]


# Read the desired metric from each output file
for icase, case in enumerate(cases):
    extractedFile = resultsDirRootName + str(icase) + '/' + extractedFileName
    fcaseMetrics = data_IO.open_file(extractedFile, 'r')
    caseOutStr = ""

    for param in paramTable:
        param_icase = data_IO.read_float_from_file_pointer(fcaseMetrics,param[0],
                                                           ',', param[1])
        caseOutStr += "," + str(param_icase)
    caselist[icase] += caseOutStr
    fcaseMetrics.close()


# Write the Desing Explorer csv file:
f = open(outcsvFileAddress, "w")
f.write(header+'\n')
casel = "\n".join(caselist)
f.write(casel+'\n')
f.close()
