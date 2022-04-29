import json
import sys
file_name = sys.argv[1]
file_type = sys.argv[2]


if file_type == "mkl":
    kw1 = '_MklFusedMatMul'
    kw2 = '_MklMatMul'
elif file_type == "default":
    kw1 = '_FusedMatMul'
    kw2 = 'MatMul'
else:
    raise ValueError("[ERROR] Wrong parameter!")

file = json.load(open(file_name))
te=file['traceEvents']
dic = {}
for item in te:
    if item['name'] == kw1 or item['name'] == kw2:
        list_ = []
        args = item['args']
        op_name=args['name']
        list_.append(float(item['dur']/1000))
        list_.append(item['name'])
        dic[op_name]=list_

for key in dic.keys():
    if dic[key][1] == kw1:
        print(' time:{:.03f}ms \t\t op_type:{}\t op_name : {}'.format(dic[key][0], dic[key][1], key))


for key in dic.keys():
    if dic[key][1] == kw2:
        print(' time:{:.03f}ms \t\t op_type:{}\t\t op_name : {}'.format(dic[key][0], dic[key][1], key))




