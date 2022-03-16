# 执行单个模型的测试 $1 单个模型的yaml文件名称


function echoColor() {
	case $1 in
	green)
		echo -e "\033[32;40m$2\033[0m"
		;;
	red)
		echo -e "\033[31;40m$2\033[0m"
		;;
	*)
		echo "Example: echo_color red string"
		;;
	esac
}

function printLine() {
	if [ ! $1 ]; then
		outword='='
	else
		outword=$1
	fi
	shellwidth=$(stty size | awk '{print $2}')
	yes $outword | sed $shellwidth'q' | tr -d '\n'
}

function printErrorTips()
{
        echoColor red "##########################################"
        echoColor red "#########        ERROR            ########"
        echoColor red "###     $1     ####"
        echoColor red "##########################################"
}

function CheckTimeOut(){
    second=$1
    targetStatus=$2
    echoColor red "target status is $targetStatus"
    ready="no"

    while [[ $second > 0 && "$ready" != "yes" ]]
    do
        declare -i index=601-$second
        echo " +++++++++++++++++++++this is the $index th check+++++++++++++++++++++++++++++++++++++"
        i=1
        status_=$(kubectl get pods |awk -F " " '{print $3}')
        workers_=$(kubectl get pods |awk -F " " '{print $1}')
        declare -a status_arr=($status_)
        declare -a worker_arr=($workers_)

        display_list=$(kubectl get pods |awk -F " " '{print $1 "  "  $2 "  " $3}')
        echoColor green "The pods list and their status is :"
        echoColor green "$display_list"
        length=${#status_arr[@]}
        for (( ; i<length;i++ ))
        do
            if [[ "${status_arr[i]}" != "$targetStatus" ]];then
                echoColor red "The status of pod $i is not Ready, it's status is ${status_arr[i]}..."
                if [[ "${status_arr[i]}" == *Err* ]];then 
                    echoColor red "===================this is the log of ${worker_arr[i]}===================="
                    kubectl logs ${worker_arr[i]}
                    echoColor red "===================this is the log of ${worker_arr[i]}===================="
                    kubectl delete tfjob trainer
                    return 1
                fi
                break
            fi
        done
        if [[ $i == $length ]]; then
            ready="yes"
        fi

        sleep 5s
        let second--
        echo "=======================TimeOut Check=====$second seconds left========================="
    done

    if [[ "$ready" == "yes" ]]; then
        echoColor green "Now the status is all $targetStatus, the process will go on..."
        return 0
    else
        echoColor red "The waiting time is over but the status is wrong , the process will be closed..."
        kubectl delete tfjob trainer
        return 1
    fi
}


function switchAndTrainModel()
{
    printLine
    echo "=============in the switchAndTrainModel function=============="
    yaml_file=$1
    echo "now the $yaml_file model is training ........."

    yaml_file_name=$(echo $yaml_file|awk -F "." '{print $1}')
    log_suffix=".log"
    kubectl create -f $yaml_file_dir/$yaml_file
    resval=$?
    echoColor green "The return value of create a k8s job is $resval"
    # 判断是否成功创建任务
    if [ "$resval" -ne "0" ]; then
        printErrorTips "faild to create k8s job"
        kubectl delete tfjob trainer
    fi

    #sleep 3s
    # 判断是否超时，若超时则退出当前任务，执行下一个任务
    echo "start check the status of all the pods ... " 
    CheckTimeOut 600 "Running"
    res=$? 
    echoColor red "The return vale of function CheckTimeOut is $res!!!!"
    if [[ "$res" == 1 ]];then
        echoColor red "The task $yaml_file has something during its running , we will skip this task ... "
        return -1
    fi

    # 判断当前集群的运行状态 等待运行完成

    flag=1
    while [[ $flag == 1 ]]
    do
        statuses=$(kubectl get pods | awk -F " " '{print $3}')
        for status in ${statuses}
        do 
            if [[ $status == "ERROR" ]];then
                echoColor red  "The status of one of the pods is 'Error', we will end up this task and skip to the next"
                break
            elif [[ $status == "Completed" ]];then
                log=$(kubectl logs trainer-worker-0 | tail -n 1)
                number=$(echo $log | awk -F " " '{print $4}' )
                if [[ $log == *"Saving"* && $number != 0 ]];then
                    flag=0
                fi
            fi
        done
                echo "    ps-0  ps-1  ps-2  ps-3  worker-0  worker-1  worker-2  worker-3  worker-4  worker-5  worker-6  worker-7  worker-8  worker-9"
                echo $statuses

        sleep 30s
    done
    kubectl logs trainer-worker-0 > $log_base_dir/$currentTime/$yaml_file_name.log \
    && kubectl delete tfjobs trainer
    echo "=============out the switchAndTrainModel function=============="
    printLine 
}

function distributed_test()
{   
    yaml_list=$(ls $yaml_file_dir | awk -F " " '{print $1}')
    #yaml_list=$(ls $yaml_file_dir |grep dssm|grep tf_fp32| awk -F " " '{print $1}')
    printLine 
    echoColor green "yaml list is ："
    echoColor green "$yaml_list"
    
    for yaml_file in ${yaml_list}
    do 
        switchAndTrainModel "$yaml_file"
        echoColor green "sleeping for 2 minutes for deleting the last job...."
        sleep 2m
    done
}

set -x
log_tag=$1
log_base_dir='./logs'
echoColor green "log_base_dir is ####$log_base_dir####"
currentTime=`date "+%Y-%m-%d-%H-%M-%S"`
echoColor green "currentTime is ####$currentTime####"
if [[ -z $log_tag ]];then
	log_dir=$log_base_dir/$currentTime
else
	log_dir=$log_base_dir/$log_tag
fi
echoColor green "log_dir is ####$log_dir####"
yaml_file_dir='./yaml_file'
echoColor green "yaml_file_dir is ####$yaml_file_dir####"

mkdir $log_dir \
&& distributed_test 
wait
python3 gstep_compute.py --log_dir ./logs/$currentTime

