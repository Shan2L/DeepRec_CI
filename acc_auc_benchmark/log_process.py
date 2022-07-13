import time
import re
import argparse
import os
import yaml
import csv

import pandas as pd


def get_arg_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--log_dir',
                        help='Full path of log directory',
                        required=False,
                        default='./')
    return parser


def read_config():
    bs_dic = {}
    cur_path = os.path.dirname(os.path.realpath(__file__))
    config_path = os.path.join(cur_path, "config.yaml")
    models=[]
    with open(config_path, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f.read())
        models  = config["test_model"]
        stock_tf = config["stocktf"]
        for model in models:
            bs_dic[model]=config['model_batchsize'][model]
            
        print("=" * 30)
        print('%-20s%s'%("Model", "batch_size"))
        for model in models:
            print('%-20s%s'%(model, bs_dic[model]))
        print("=" * 30)
    return stock_tf, bs_dic, models


if __name__ == "__main__":
    stock_tf, bs_dic, models = read_config()
    parser = get_arg_parser()
    args = parser.parse_args()
    log_dir = args.log_dir

    log_list = []
    result={}
    for root, dirs, files in os.walk(log_dir, topdown=False):
        for name in files:
            if os.path.splitext(name)[1] == '.log':
                log_list.append(os.path.join(root, name))
    acc_dic = {}
    auc_dic = {}
    for file in log_list:
        output = []
        file_name = os.path.split(file)[1]
        model_name = file_name.split('_')[0]
        file_name_nosurf = os.path.splitext(file_name)[0]
        with open(file, 'r') as f:
            for line in f:
                if "ACC" in line:
                    value = float(line.split()[2])
                    acc_dic[file_name_nosurf] = value
                if "AUC" in line:
                    value = float(line.split()[2])
                    auc_dic[file_name_nosurf] = value
    
    
    total_dic = {}
    for model in models:
        total_dic[model]= {}
        total_dic[model]["acc"]={}
        total_dic[model]["auc"]={}
        for acc_key in acc_dic.keys():
            if model.lower() in acc_key:
                if "tf_fp32" in acc_key:
                    total_dic[model]["acc"]["tf_fp32"]=acc_dic[acc_key]
                elif "deeprec_fp32" in acc_key:
                    total_dic[model]["acc"]["deeprec_fp32"]=acc_dic[acc_key]
                elif "deeprec_bf16" in acc_key:
                    total_dic[model]["acc"]["deeprec_bf16"]=acc_dic[acc_key]
        for auc_key in auc_dic.keys():
            if model.lower() in auc_key:
                if "tf_fp32" in auc_key:
                    total_dic[model]["auc"]["tf_fp32"]=auc_dic[auc_key]
                elif "deeprec_fp32" in auc_key:
                    total_dic[model]["auc"]["deeprec_fp32"]=auc_dic[auc_key]
                elif "deeprec_bf16" in auc_key:
                    total_dic[model]["auc"]["deeprec_bf16"]=auc_dic[auc_key]            


    upgrade_dic = {}
    
    f1 = open('./acc.csv', 'w',encoding='utf-8')
    f1_writer = csv.writer(f1)
    f1_writer.writerow(["ACC"])
    f1_writer.writerow(["Community TF"])
    f1_writer.writerow(["DeepRec FP32"])
    f1_writer.writerow(["DeepRec BF16"])
    f1.close()
    f2 = open('./auc.csv', 'w',encoding='utf-8')
    f2_writer = csv.writer(f2)
    f2_writer.writerow(["AUC"])
    f2_writer.writerow(["Community TF"])
    f2_writer.writerow(["DeepRec FP32"])
    f2_writer.writerow(["DeepRec BF16"])
    f2.close()
    csvPD=pd.read_csv('./acc.csv')

    csvPD_auc=pd.read_csv("./auc.csv")
    # 
    # csvPD['acc'] = 'Community TF'
    # csvPD['acc']='DeepRec FP32'
    # csvPD['acc']='DeepRec BF16'
    
    # csvPD_auc['auc']='Community TF'
    # csvPD_auc['auc']='DeepRec FP32'
    # csvPD_auc['auc']='DeepRec BF16'

    for model in models:
        upgrade_dic[model] = {}
        upgrade_dic[model]['tf_fp32'] = 'baseline'
        if stock_tf:
            upgrade_dic[model]['acc_deeprec_fp32'] = total_dic[model]['acc']['deeprec_fp32'] / total_dic[model]['acc']['tf_fp32'] 
            upgrade_dic[model]['acc_deeprec_bf16'] = total_dic[model]['acc']['deeprec_bf16'] / total_dic[model]['acc']['tf_fp32']
            upgrade_dic[model]['auc_deeprec_fp32'] = total_dic[model]['auc']['deeprec_fp32'] / total_dic[model]['auc']['tf_fp32']
            upgrade_dic[model]['auc_deeprec_bf16'] = total_dic[model]['auc']['deeprec_bf16'] / total_dic[model]['auc']['tf_fp32']

    if stock_tf:
        print("%-5s\t %10s\t %-10s\t %-10s\t %-10s\t %-11s\t %11s" %('Model', 'FrameWork', 'Datatype', 'ACC', 'AUC',  'acc_Speedup', 'auc_Speedup'))    
        for model in total_dic.keys():
            print(model+':')
            print("%-5s\t %10s\t %-10s\t %-10.6f\t %-5.6f\t %11s\t " %('', 'StockTF', 'FP32',  total_dic[model]['acc']['tf_fp32'], total_dic[model]['auc']['tf_fp32'],  upgrade_dic[model]['tf_fp32']),  upgrade_dic[model]['tf_fp32'])
            print("%-5s\t %10s\t %-10s\t %-10.6f\t %-5.6f\t %10.2f%%\t %10.2f%%" %('', 'DeepRec', 'FP32',  total_dic[model]['acc']['deeprec_fp32'], total_dic[model]['auc']['deeprec_fp32'], upgrade_dic[model]['acc_deeprec_fp32']*100, upgrade_dic[model]['auc_deeprec_fp32']*100))
            print("%-5s\t %10s\t %-10s\t %-10.6f\t %-5.6f\t %10.2f%%\t %10.2f%%" %('', 'DeepRec', 'BF16',  total_dic[model]['acc']['deeprec_bf16'], total_dic[model]['auc']['deeprec_bf16'], upgrade_dic[model]['acc_deeprec_bf16']*100,  upgrade_dic[model]['auc_deeprec_bf16']*100))
            # insert_acc_num = {total_dic[model]['acc']['tf_fp32'], total_dic[model]['acc']['deeprec_fp32'], total_dic[model]['acc']['deeprec_bf16']}
            
            insert_acc_num = [total_dic[model]['acc']['tf_fp32'], total_dic[model]['acc']['deeprec_fp32'], total_dic[model]['acc']['deeprec_bf16']]
            csvPD[model]=insert_acc_num
            

            insert_acc_pre = [upgrade_dic[model]['tf_fp32'], upgrade_dic[model]['acc_deeprec_fp32']*100, upgrade_dic[model]['acc_deeprec_fp32']*100]
            csvPD[model+'_percent']=insert_acc_pre
            
            insert_auc_num = [total_dic[model]['auc']['tf_fp32'], total_dic[model]['auc']['deeprec_fp32'], total_dic[model]['auc']['deeprec_bf16']]
            csvPD_auc[model]=insert_auc_num
            insert_auc_pre = [upgrade_dic[model]['tf_fp32'], upgrade_dic[model]['auc_deeprec_fp32']*100, upgrade_dic[model]['auc_deeprec_fp32']*100]
            csvPD_auc[model+'_percent']=insert_auc_pre
           
            csvPD.to_csv("./acc.csv", index =False, sep=',' )
            
            csvPD_auc.to_csv("./auc.csv", index =False, sep=',' )


    else:
        print("%-5s\t %10s\t %-10s\t %-10s\t %-11s\t %10s\t %10s\t" %('Model', 'FrameWork', 'Datatype', 'ACC', 'AUC',  'acc_Speedup', 'auc_Speedup'))
        for model in total_dic.keys():
            print(model+':')
            print("%-5s\t %10s\t %-10s\t %-10.6f\t %-5.6f\t %10.2f%%\t %10.2f%%" %('', 'DeepRec', 'FP32',  total_dic[model]['acc']['deeprec_fp32'], total_dic[model]['auc']['deeprec_fp32'], upgrade_dic[model]['acc_deeprec_fp32']*100, upgrade_dic[model]['auc_deeprec_fp32']*100))
            print("%-5s\t %10s\t %-10s\t %-10.6f\t %-5.6f\t %10.2f%%\t %10.2f%%" %('', 'DeepRec', 'BF16',  total_dic[model]['acc']['deeprec_bf16'], total_dic[model]['auc']['deeprec_bf16'],  upgrade_dic[model]['acc_deeprec_bf16']*100,  upgrade_dic[model]['auc_deeprec_bf16']*100))

   
