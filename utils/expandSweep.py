import sys
import math
import itertools as it

params = sys.argv[1];
out = sys.argv[2];

with open(params) as f:
    content = f.read().splitlines()


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
            pval = [pval]
        pvals[pname] = pval

varNames = sorted(pvals)
cases = [[{varName: val} for varName, val in zip(varNames, prod)] for prod in
         it.product(*(pvals[varName] for varName in varNames))]

print("Generated " + str(len(cases)) + " Cases")

caselist = []
for c in cases:
    case = ""
    for p in c:
        pname = p.keys()[0]
        pval = p[pname]
        case += pname + "=" + pval + ","
    caselist.append(case[:-1])

casel = "\n".join(caselist)

f = open(out, "w")
f.write(casel)
f.close()
