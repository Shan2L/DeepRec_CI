# 将要在容器中执行的命令归档
function make_script()
{
    IFS_old=$IFS
    IFS=$'\n'
    make_single_script deeprec_bf16 $deeprec_bf16_script
    make_single_script deeprec_fp32 $deeprec_fp32_script
    make_single_script tf_fp32 $tf_fp32_script
    IFS=$IFS_old
}

function make_single_script()
{
    catg=$1
    script=$2
    # 记录运行的命令脚本
    bf16_para=
    [[ ! -d $(dirname $script) ]] && mkdir -p $(dirname $script)
    [[ $catg != "tf_fp32" ]] && echo "$env_var" > $script && echo " " >> $script
    [[ $catg == "deeprec_bf16" ]] && bf16_para="--bf16"
        
    for line in $(cat $config_file | grep CMD | grep $catg )
    do
        command=$(echo "$line" | awk -F ":" '{print $2}'| awk -F "|" '{print $1}')
        paras=$(echo "$line" | awk -F ":" '{print $2}' | awk -F "|" '{print $2}')
        log_tag=$(echo $paras| sed 's/ /_/g')
        model_name=$(echo "${line}" | awk -F ":" '{print $1}' | awk -F " " '{print $2}' | awk -F "_" '{print $1}')
        echo "echo 'testing $model_name of deeprec_bf16 $paras.......'" >> $script
        echo "/root/modelzoo/$model_name/" >> $script
      	if [[ ! -d  $checkpoint_dir$currentTime/${model_name,,}_script$$log_tag ]];then
      		sudo mkdir -p $checkpoint_dir$currentTime/${model_name,,}_$script$log_tag
      	fi
        if [[  $weekly != 'true' ]];then
            newline="$command $paras  $bf16_para --checkpoint $checkpoint_dir$currentTime/${model_name,,}_$catg$log_tag  >$log_dir$currentTime/${model_name,,}_$catg$log_tag.log 2>&1"
        else
            newline="$command  $bf16_para --checkpoint $checkpoint_dir$currentTime/${model_name,,}_$catg  >$log_dir$currentTime/${model_name,,}_$catg.log 2>&1"
        fi
        echo $newline >> $script
    done
}

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


function runSingleContainer()
{
    image_repo=$1
    script_name=$2
    container_name=$(echo $2 | awk -F "." '{print $1}')
    host_path=$(cd ./benchmark_result && pwd)
    cpu_item=
    if [[ -n $cpus ]];then
        optional="--cpuset-cpus $cpus"
    fi
    sudo docker run -itd \
    	--name $container_name\
        --rm\
        $optional \
        -v $host_path:/benchmark_result/\
        $image_repo /bin/bash /benchmark_result/record/script/$currentTime/$script_name  
}

function runContainers()
{
    if [[ -n $deeprec_bf16_CMD ]];then
        runSingleContainer $deeprec_test_image deeprec_bf16.sh
    fi

    if [[ -n $deeprec_fp32_CMD ]];then
        runSingleContainer $deeprec_test_image deeprec_fp32.sh
    fi

    if [[ -n $tf_fp32_CMD ]];then
        runSingleContainer $tf_test_image tf_fp32.sh
    fi
}

function checkEnv()
{   
    status1=$(sudo docker ps -a | grep deeprec_bf16)
    status2=$(sudo docker ps -a | grep deeprec_fp32)
    status3=$(sudo docker ps -a | grep tf_fp32)
    if [[  -n $status1 ]];then
        sudo docker rm -f deeprec_bf16
    fi
    if [[  -n $status2 ]];then
        sudo docker rm -f deeprec_fp32
    fi
    if [[  -n $status3 ]];then
        sudo docker rm -f tf_fp32
    fi
}

function checkStatus()
{

    echo "sleep for 2 min ....."
    sleep 2m
    tf_32_status=$(sudo docker ps -a |grep tf_fp32| awk -F " " '{print $8$9}')
    deeprec_32_status=$(sudo docker ps -a |grep deeprec_fp32| awk -F " " '{print $8$9}')
    deeprec_16_status=$(sudo docker ps -a |grep deeprec_bf16| awk -F " " '{print $8$9}')
    echo "tf32:${tf_32_status}"
    echo "deeprec32:${deeprec_32_status}"
    echo "deeprec16:${deeprec_16_status}"

    while [[ "$tf_32_status" == *"Up"* || "${deeprec_32_status}" == *"Up"* || "${deeprec_16_status}" == *"Up"* ]]
    do
        tf_32_status=$(sudo docker ps -a |grep tf_fp32| awk -F " " '{print $6$7$8$9$10}')
        deeprec_32_status=$(sudo docker ps -a |grep deeprec_fp32| awk -F " " '{print $6$7$8$9$10}')
        deeprec_16_status=$(sudo docker ps -a |grep deeprec_bf16| awk -F " " '{print $6$7$8$9$10}')

        echo "----------------------------------------------------"
        echo "the status of tf_fp32 is $tf_32_status...          |"
        echo "the status of deeprec_32 is $deeprec_32_status...  |"
        echo "the status of deeprec_16 is $deeprec_16_status...  |"
        echo "---------------------------------------------------"
        echo ""

        if [[ "$tf_32_status" == *"Exited"* ]]; then
            echoColor red "Container tf_fp32 has exited..."
        fi

        if [[ "$deeprec_32_status" == *"Exited"* ]]; then
            echoColor red "Container deeprec_fp32 has exited..."
        fi

        if [[ "$deeprec_16_status" == *"Exited"* ]]; then
            echoColor red "Container deeprec_bf16 has exited..."
        fi

        echo "sleep for 1 min ......"
        sleep 1m
        
    done

    # 如果三个镜像都已经执行完成
    echo "All of the three have finished the task"

}

function push_to_git()
{ 
	git add ./benchmark_result/log/$currentTime/* 
	if [[ $weekly == 'true' ]];then
		git commit -m "[Regression Benchmark] Add log directory of $currentTime, and the DeepRec image is $dp_tag  the TF image is $tf_tag" 
	else
		git commit -m "[Benchmark] Add log directory of $currentTime, and the DeepRec image is $dp_tag  the TF image is $tf_tag" 
	fi
	git push
	while [[ $? != 0 ]]
	do
		git push
	done
	echo "Finsh pushing to Github"	
}


# set -x
# 获取当前时间戳
currentTime=`date "+%Y-%m-%d-%H-%M-%S"`

# 配置文件的存放位置
config_file="./config.properties"

# 读取目录配置
log_dir=$(cat $config_file |grep log_dir | awk -F " " '{print $2}')
checkpoint_dir=$(cat $config_file | grep checkpoint_dir | awk -F " " '{print $2}')

# 主机上的存放位置
gol_dir=$(cat $config_file |grep gol_dir | awk -F " " '{print $2}')
pointcheck_dir=$(cat $config_file | grep pointcheck_dir | awk -F " " '{print $2}')


# 测试命令脚本存放的位置
deeprec_fp32_script="./benchmark_result/record/script/$currentTime/deeprec_fp32.sh"
deeprec_bf16_script="./benchmark_result/record/script/$currentTime/deeprec_bf16.sh"
tf_fp32_script="./benchmark_result/record/script/$currentTime/tf_fp32.sh"

# 从配置文件中读测试镜像的名称
deeprec_test_image=$(cat $config_file |grep deeprec_test_image | awk -F " " '{print$2}' )
tf_test_image=$(cat $config_file |grep tf_test_image | awk -F " " '{print$2}' )


# 拉取测试镜像
sudo docker pull $deeprec_test_image
sudo docker pull $tf_test_image

# 从配置文件读取测试的命令
deeprec_bf16_CMD=$(cat $config_file | grep CMD | grep deeprec_bf16 | awk -F ":" '{print$2}')
deeprec_fp32_CMD=$(cat $config_file | grep CMD | grep deeprec_fp32 | awk -F ":" '{print$2}')
tf_fp32_CMD=$(cat $config_file | grep CMD | grep tf_fp32 | awk -F ":" '{print$2}')


# 从配置文件读取cpu限制
cpus=$(cat $config_file | grep cpus | awk -F " " '{print $2}')

# 从配置文件读取测试环境变量配置
env_var=$(cat $config_file |grep export)


# 创建目录
if [ ! -d $gol_dir$currentTime ];then
    sudo mkdir -p "$gol_dir$currentTime" 
fi 
if [ ! -d $pointcheck_dir$currentTime ];then
    sudo mkdir -p "$pointcheck_dir$currentTime"
fi

make_script\
&& checkEnv\
&& runContainers\
&& checkStatus \
&& sudo python ./acc_auc_count.py --log_dir=$gol_dir$currentTime


