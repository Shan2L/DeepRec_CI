![distributed.png](https://github.com/GosTraight2020/DeepRec_CI/blob/master/.asset/distributed.png)
## How to Benchmark Distributed Global steps
**The process of distributed Global Steps Benchmark**
1. Modify the template yaml file with Image name etc.
2. Run gen_template.py to generate yaml files accroding to the template yaml file modified last step.
3. Run distributed_test.sh to create tasks by the yamls file produces in steps 2 
4. The distributes_test.sh will collect the log file one by one automaticaly.
5. Use gstep.py to produce the final gstep.csv file 

Tips: You can ues GitHub Action UI interface to implement above steps.
https://github.com/GosTraight2020/DeepRec_CI/actions/workflows/dis.yml

**How to use**
1. Modyfy the template yaml file .
2. Run gen_template.py to generate yaml files.
3. run distributed_test.sh
