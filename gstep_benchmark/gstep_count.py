import time
import re
import argparse
import os
import csv

def get_arg_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--log_dir',
                        help='Full path of log directory',
                        required=False,
                        default='./')
    return parser


if __name__ == "__main__":
    parser = get_arg_parser()
    args = parser.parse_args()
    log_dir = args.log_dir

    log_list = []
    result={}
    for root, dirs, files in os.walk(log_dir, topdown=False):
        for name in files:
            # print(os.path.join(root, name))
            # print(name)
            if os.path.splitext(name)[1] == '.log':
                log_list.append(os.path.join(root, name))
    print(log_list)

    for file in log_list:
        output = []
        with open(file, 'r') as f:
            for line in f:
                matchObj = re.search(r'global_step/sec: \d+(\.\d+)?', line)
                if matchObj:
                    output.append(matchObj.group()[17:])
        # gstep = float(output[-11:-1])
        gstep = [float(i) for i in output[-11:-1]]
        avg = sum(gstep) / len(gstep)
        filename = os.path.splitext(os.path.split(file)[1])[0]
        # print('%f\t' % avg + filename)
        result[filename]=round(avg,6)
    for (key, value) in result.items():
        print("key:"+key)

    for model_name in ["dien", "din", "dlrm", "dssm", "deepfm", "wdl"]:

        result[model_name+"_tf_fp32"] = result[model_name+"_tf_fp32"] if model_name+"_tf_fp32" in result else "-"    
        result[model_name+"_deeprec_bf16"] = result[model_name+"_deeprec_bf16"] if model_name+"_deeprec_bf16" in result else "-"      
        result[model_name+"_deeprec_fp32"] = result[model_name+"_deeprec_fp32"] if model_name+"_deeprec_fp32" in result else "_"

        tf_fp32 = result[model_name+"_tf_fp32"]
        deeprec_bf16 = result[model_name+"_deeprec_bf16"] 
        deeprec_fp32 = result[model_name+"_deeprec_fp32"]
        
        tf_fp32_flag = tf_fp32 == "-"
        deeprec_bf16_flag = deeprec_bf16 == "-"
        deeprec_fp32_flag = deeprec_fp32 == "-"



        result[model_name + "_deeprec_bf16_ratio"] = "-" if deeprec_bf16_flag or tf_fp32_flag else "{:.2f}%".format((deeprec_bf16 / tf_fp32)*100)
        result[model_name + "_deeprec_fp32_ratio"] = "-" if deeprec_fp32_flag or tf_fp32_flag else "{:.2f}%".format((deeprec_fp32 / tf_fp32)*100)
        result[model_name + "_tf_fp32_ratio"] = "baseline"


    for key in sorted(result):
        print('{}'.format(result[key])+'\t{}'.format(key))

    

    with open(log_dir+"/gstep_result.csv",'w')as f:
        writer = csv.writer(f)
        head1 = ["Gstep", " ", "WDL", "WDL", "DLRM", "DLRM", "Deep FM", "Deep FM", "DSSM",  "DSSM", "DIEN", "DIEN", "DIN", "DIN"]
        print(head1)
        writer.writerow(head1)
        head2 = ["Gstep", " ", "value", "percent", "value", "percent", "value", "percent", "value", "percent", "value", "percent", "value", "percent"]
        print(head2)
        writer.writerow(head2)

        data = ["Commuty TF", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(result[model_name+"_tf_fp32"])
            data.append(result[model_name + "_tf_fp32_ratio"])
        writer.writerow(data)
        
        data = ["DeepRec FP32", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(result[model_name+"_deeprec_fp32"])
            data.append(result[model_name + "_deeprec_fp32_ratio"])
        print(data)
        writer.writerow(data)

        data = ["DeepRec BF16", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(result[model_name+"_deeprec_bf16"])
            data.append(result[model_name + "_deeprec_bf16_ratio"])
        print(data)
        writer.writerow(data)

