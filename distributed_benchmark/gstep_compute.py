import time
import re
import argparse
import os
import csv
#import matplotlib.pyplot as plt
import numpy as np

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
            if os.path.splitext(name)[1] == '.log':
                log_list.append(os.path.join(root, name))

    result = {}    
    for log_file in log_list:
        values = []
        print("file:{}".format(log_file))
        with open(log_file, 'r') as f:
            for line in f:
                matchObj = re.search(r'global_step/sec: \d+(\.\d+)?', line)

                if matchObj:

                    temp = (matchObj.group()[17:])
                    values.append(float(temp))
       
        filename = os.path.split(log_file)[1]
        filename_nosuf = os.path.splitext(filename)[0]

        if(len(values)==0):
               print("{} :error".format(log_file))
               continue
        pre_avg = sum(values) / len(values)
 #       print("the unprocessed data's length is {}, and it's average value is {}".format(len(values), pre_avg))    
        head = round(len(values) * 0.4)
        tail = round(len(values) * 0.9)
        values = values[head:tail]
        
#        plt.figure()
#        plt.plot(np.arange(0, len(values)), values)
#        plt.title(filename_nosuf)
#        plt.savefig(log_dir+"/"+filename_nosuf+".png")
#        plt.close()

        avg = sum(values) / len(values)
  #      print("the processed data's length is {}, and it's average value is {}". format(len(values), avg))
        result[filename_nosuf] = avg
        
    keys = []
    for (key, value) in result.items():
        keys.append(key)
        
    for model_name in ["dlrm", "dssm", "deepfm", "wdl", "dien", "din"]:
        tf_name = "tf_fp32_"+model_name
        dp16_name = "deeprec_bf16_"+model_name
        dp32_name ="deeprec_fp32_"+model_name

        result[model_name + "_tf_fp32_ratio"] = "baseline"
        if tf_name not in keys and dp16_name not in keys and dp32_name not in keys:
            result[tf_name] = "-"
            result[dp16_name] = "-"
            result[dp32_name] = "-"
            result[model_name + "_deeprec_bf16_ratio"] = "-"
            result[model_name + "_deeprec_fp32_ratio"] = "-"
        elif tf_name in keys and dp16_name in keys and dp32_name in keys:
            tf_fp32 = result[tf_name]
            deeprec_bf16 = result[dp16_name]
            deeprec_fp32 = result[dp32_name]
            result[model_name + "_deeprec_bf16_ratio"] = "{:.2f}%".format((deeprec_bf16 / tf_fp32)*100)
            result[model_name + "_deeprec_fp32_ratio"] = "{:.2f}%".format((deeprec_fp32 / tf_fp32)*100)
            result[model_name + "_tf_fp32_ratio"] = "baseline"
        else:
            if tf_name not in keys:
                result[tf_name] = "-"
                if dp16_name not in keys:
                    result[dp16_name] = "-"
                    result[model_name + "_deeprec_bf16_ratio"] = "-"
                    deeprec_bf16 = result[dp32_name]
                    result[model_name + "_deeprec_fp32_ratio"] = "-"

                else:
                    deeprec_bf16 = result[dp16_name]
                    result[model_name + "_deeprec_bf16_ratio"] = "-"
                    
                    if dp32_name not in keys:
                        result[dp32_name] = "-"
                        result[model_name + "_deeprec_fp32_ratio"] = "-"
                    else:
                        deeprec_fp32 = result[dp32_name]
                        result[model_name + "_deeprec_fp32_ratio"] = "-"

            else:
                tf_fp32 = result[tf_name]
                if dp16_name not in keys:
                    result[dp16_name] = "-"
                    result[model_name + "_deeprec_bf16_ratio"] = "-"
                    if dp32_name not in keys:
                        result[dp32_name] = "-"
                        result[model_name + "_deeprec_fp32_ratio"] = "-"
                    else:
                         deeprec_fp32 = result[dp32_name]
                         result[model_name + "_deeprec_fp32_ratio"] = "{:.2f}%".format((deeprec_fp32 / tf_fp32)*100)
                else:
                     deeprec_bf16 = result[dp16_name]
                     deeprec_fp32 = "-"
                     result[model_name + "_deeprec_bf16_ratio"] = "{:.2f}%".format((deeprec_bf16 / tf_fp32)*100)
                     result[model_name + "_deeprec_fp32_ratio"] = "-"

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
            data.append(result["tf_fp32_"+model_name])
            data.append(result[model_name + "_tf_fp32_ratio"])
        writer.writerow(data)
        
        data = ["DeepRec FP32", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(result["deeprec_fp32_"+model_name])
            data.append(result[model_name + "_deeprec_fp32_ratio"])
        print(data)
        writer.writerow(data)

        data = ["DeepRec BF16", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(result["deeprec_bf16_"+model_name])
            data.append(result[model_name + "_deeprec_bf16_ratio"])
        print(data)
        writer.writerow(data)
