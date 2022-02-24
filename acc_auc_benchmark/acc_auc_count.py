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
    for root, dirs, files in os.walk(log_dir, topdown=False):
        for name in files:
            # print(os.path.join(root, name))
            # print(name)
            if os.path.splitext(name)[1] == '.log':
                log_list.append(os.path.join(root, name))
    print(log_list)

    acc_dic = {}
    auc_dic = {}
    for file in log_list:
       # output = []
        print(file)
        file_name = os.path.split(file)[1]
        file_name_nosurf = os.path.splitext(file_name)[0]
        with open(file, 'r') as f:
            for line in f:
                if "ACC" in line:
                    value = float(line.split()[2])
                    acc_dic[file_name_nosurf] = value

                elif "AUC" in line:
                    value = float(line.split()[2])
                    auc_dic[file_name_nosurf] = value

    keys = []
    for (key, value) in acc_dic.items():
        print("key:"+key )
        keys.append(key)


    for dic in [acc_dic, auc_dic]:
        for model_name in ["dlrm", "dssm", "deepfm", "wdl", "dien", "din"]:
            tf_name = model_name+"_tf_fp32"
            dp16_name = model_name+"_deeprec_bf16"
            dp32_name = model_name+"_deeprec_fp32"

            dic[tf_name+"_ratio"] = "baseline"
            
            if tf_name not in keys and dp16_name not in keys and dp32_name not in keys:
                dic[tf_name] = "-"
                dic[dp16_name] = "-"
                dic[dp32_name] = "-"
                dic[model_name + "_deeprec_bf16_ratio"] = "-"
                dic[model_name + "_deeprec_fp32_ratio"] = "-"
            elif tf_name in keys and dp16_name in keys and dp32_name in keys:
                tf_fp32 = dic[tf_name]
                deeprec_bf16 = dic[dp16_name]
                deeprec_fp32 = dic[dp32_name]
                dic[model_name + "_deeprec_bf16_ratio"] = "{:.2f}%".format((deeprec_bf16 / tf_fp32)*100)
                dic[model_name + "_deeprec_fp32_ratio"] = "{:.2f}%".format((deeprec_fp32 / tf_fp32)*100)
                dic[model_name + "_tf_fp32_ratio"] = "baseline"
            else:
                if tf_name not in keys:
                    dic[tf_name] = "-"
                    if dp16_name not in keys:
                        dic[dp16_name] = "-"
                        dic[model_name + "_deeprec_bf16_ratio"] = "-"
                        deeprec_bf16 = dic[dp32_name]
                        dic[model_name + "_deeprec_fp32_ratio"] = "-"

                    else:
                        deeprec_bf16 = dic[dp16_name]
                        dic[model_name + "_deeprec_bf16_ratio"] = "-"
                        
                        if dp32_name not in keys:
                            dic[dp32_name] = "-"
                            dic[model_name + "_deeprec_fp32_ratio"] = "-"
                        else:
                            deeprec_fp32 = dic[dp32_name]
                            dic[model_name + "_deeprec_fp32_ratio"] = "-"

                else:
                    tf_fp32 = dic[tf_name]
                    if dp16_name not in keys:
                        dic[dp16_name] = "-"
                        dic[model_name + "_deeprec_bf16_ratio"] = "-"
                        if dp32_name not in keys:
                            dic[dp32_name] = "-"
                            dic[model_name + "_deeprec_fp32_ratio"] = "-"
                        else:
                            deeprec_fp32 = dic[dp32_name]
                            dic[model_name + "_deeprec_fp32_ratio"] = "{:.2f}%".format((deeprec_fp32 / tf_fp32)*100)
                    else:
                        deeprec_bf16 = dic[dp16_name]
                        deeprec_fp32 = "-"
                        dic[model_name + "_deeprec_bf16_ratio"] = "{:.2f}%".format((deeprec_bf16 / tf_fp32)*100)
                        dic[model_name + "_deeprec_fp32_ratio"] = "-"


    acc_result_path = os.path.join(log_dir, "acc_result.csv")
    with open(acc_result_path,'w')as f:
        writer = csv.writer(f)
        head1 = ["ACC", " ", "WDL", "WDL", "DLRM", "DLRM", "Deep FM", "Deep FM", "DSSM",  "DSSM", "DIEN", "DIEN", "DIN", "DIN"]
        print(head1)
        writer.writerow(head1)
        head2 = ["ACC", " ", "value", "percent", "value", "percent", "value", "percent", "value", "percent", "value", "percent", "value", "percent"]
        print(head2)
        writer.writerow(head2)

        data = ["Commuty TF", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(acc_dic[model_name+"_tf_fp32"])
            data.append(acc_dic[model_name + "_tf_fp32_ratio"])
        writer.writerow(data)
        
        data = ["DeepRec FP32", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(acc_dic[model_name+"_deeprec_fp32"])
            data.append(acc_dic[model_name+"_deeprec_fp32_ratio"])
        print(data)
        writer.writerow(data)

        data = ["DeepRec BF16", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(acc_dic[model_name+"_deeprec_bf16"])
            data.append(acc_dic[model_name+"_deeprec_bf16_ratio"])
        print(data)
        writer.writerow(data)

                
    auc_result_path = os.path.join(log_dir, "auc_result.csv")
    with open(auc_result_path,'w')as f:
        writer = csv.writer(f)
        head1 = ["AUC", " ", "WDL", "WDL", "DLRM", "DLRM", "Deep FM", "Deep FM", "DSSM",  "DSSM", "DIN", "DIN", "DIEN", "DIEN"]
        print(head1)
        writer.writerow(head1)
        head2 = ["AUC", " ", "value", "percent", "value", "percent", "value", "percent", "value", "percent","value", "percent", "value", "percent"]
        print(head2)
        writer.writerow(head2)

        data = ["Commuty TF", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(auc_dic[model_name+"_tf_fp32"])
            data.append(auc_dic[model_name + "_tf_fp32_ratio"])
        writer.writerow(data)
        
        data = ["DeepRec FP32", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(auc_dic[model_name+"_deeprec_fp32"])
            data.append(auc_dic[model_name+"_deeprec_fp32_ratio"])
        print(data)
        writer.writerow(data)

        data = ["DeepRec BF16", " "]
        for model_name in ["wdl", "dlrm", "deepfm", "dssm", "dien", "din"]:
            data.append(auc_dic[model_name+"_deeprec_bf16"])
            data.append(auc_dic[model_name+"_deeprec_bf16_ratio"])
        print(data)
        writer.writerow(data)


