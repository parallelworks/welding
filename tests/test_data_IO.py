import sys
import data_IO

inputFile = sys.argv[1]

fi = data_IO.open_file(inputFile)

delimiter = None
param2read = "line NT int"
numParameters = 1

data = data_IO.read_int_from_file_pointer(fi, param2read, delimiter,1)

print(param2read + " value(s):" + str(data))

delimiter = ','
param2read = "line NT comma int"
numParameters = 1

data = data_IO.read_int_from_file_pointer(fi, param2read, delimiter)

print(param2read + " value(s):" + str(data))


delimiter = ','
param2read = "line NT comma float"
numParameters = 1

data = data_IO.read_floats_from_file_pointer(fi, param2read,2, delimiter,1)

print(param2read + " value(s):" + str(data))


fi.close()
