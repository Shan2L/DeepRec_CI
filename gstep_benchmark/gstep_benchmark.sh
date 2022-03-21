# 将要在容器中执行的命令归档
function make_script()
{


    # 记录运行的命令脚本
    if [ ! -d $(dirname $deeprec_fp32_script) ];then
        mkdir -p $(dirname $deeprec_fp32_script)
    fi
    

    echo "$env_var" > $deeprec_bf16_script
    echo " " >> $deeprec_bf16_script
    IFS_old=$IFS
    IFS=$'\n';
    for line in $(cat $config_file | grep CMD | grep deeprec_bf16 )
    do
        command=$(echo "$line" | awk -F ":" '{print $2}'| awk -F "|" '{print $1}')
	      paras=$(echo "$line" | awk -F ":" '{print $2}' | awk -F "|" '{print $2}')
	      log_tag=$(echo $paras| sed 's/ /_/g')
        model_name=$(echo "${line}" | awk -F ":" '{print $1}' | awk -F " " '{print $2}' | awk -F "_" '{print $1}')
        echo "echo 'testing $model_name of deeprec_bf16 $paras.......'" >> $deeprec_bf16_script
        echo "cd /root/modelzoo/$model_name/" >> $deeprec_bf16_script
      	if [[ ! -d  $checkpoint_dir$currentTime/${model_name,,}_deeprec_bf16_$log_tag ]];then
      		sudo mkdir -p $checkpoint_dir$currentTime/${model_name,,}_deeprec_bf16_$log_tag
      	fi
        newline="LD_PRELOAD=/root/modelzoo/libjemalloc.so.2.5.1 $command $paras --checkpoint $checkpoint_dir$currentTime/${model_name,,}_deeprec_bf16_$log_tag --bf16 >$log_dir$currentTime/${model_name,,}_deeprec_bf16_$log_tag.log 2>&1"
        echo $newline >> $deeprec_bf16_script
    done;

    echo "$env_var" > $deeprec_fp32_script
    echo " " >> $deeprec_fp32_script
    for line in $(cat $config_file | grep CMD | grep deeprec_fp32 )
    do
        command=$(echo "$line" | awk -F ":" '{print $2}'| awk -F "|" '{print $1}')
      	paras=$(echo "$line"  | awk -F ":" '{print $2}'| awk -F "|" '{print $2}')
      	log_tag=$(echo $paras| sed 's/ /_/g')
        model_name=$(echo "${line}" | awk -F ":" '{print $1}' | awk -F " " '{print $2}' | awk -F "_" '{print $1}')
        echo "echo 'testing $model_name of deeprec_fp32 $paras.......'" >> $deeprec_fp32_script
        echo "cd /root/modelzoo/$model_name/" >> $deeprec_fp32_script
      	if [[ ! -d  $checkpoint_dir$currentTime/${model_name,,}_deeprec_bf16_$log_tag ]];then
      		sudo mkdir -p $checkpoint_dir$currentTime/${model_name,,}_deeprec_bf16_$log_tag
      	fi

        newline="LD_PRELOAD=/root/modelzoo/libjemalloc.so.2.5.1 $command $paras --checkpoint $checkpoint_dir$currentTime/${model_name,,}_deeprec_fp32_$log_tag >$log_dir$currentTime/${model_name,,}_deeprec_fp32_$log_tag.log 2>&1"
        

        echo $newline >> $deeprec_fp32_script
    done;

    for line in $(cat $config_file | grep CMD | grep tf_fp32 )
    do
        command=$(echo "$line" | awk -F ":" '{print $2}'| awk -F "|" '{print $1}')
      	paras=$(echo "$line" |awk -F ":" '{print $2}' | awk -F "|" '{print $2}')
      	log_tag=$(echo $paras| sed 's/ /_/g')
        model_name=$(echo "${line}" | awk -F ":" '{print $1}' | awk -F " " '{print $2}' | awk -F "_" '{print $1}')
        echo "echo 'testing $model_name of tf_fp32 $paras.......'" >> $tf_fp32_script
        echo "cd /root/modelzoo/$model_name/" >> $tf_fp32_script
      	if [[ ! -d  $checkpoint_dir$currentTime/${model_name,,}_deeprec_bf16_$log_tag ]];then
      		sudo mkdir -p $checkpoint_dir$currentTime/${model_name,,}_deeprec_bf16_$log_tag
      	fi

        newline="LD_PRELOAD=/root/modelzoo/libjemalloc.so.2.5.1 $command $paras --checkpoint $checkpoint_dir$currentTime/${model_name,,}_tf_fp32_$log_tag >$log_dir$currentTime/${model_name,,}_tf_fp32_$log_tag.log 2>&1"
        
        echo $newline >> $tf_fp32_script
    done;
    IFS=$IFS_old
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
    host_path=$(cd benchmark_result && pwd) 
    sudo docker run -it --name $container_name\
        $cpu_set\
	--rm \
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




set -x
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

# 拉取最新的测试镜像
sudo docker pull $deeprec_test_image
sudo docker pull $tf_test_image


# 从配置文件读取测试的命令
deeprec_bf16_CMD=$(cat $config_file | grep CMD | grep deeprec_bf16 | awk -F ":" '{print$2}')
deeprec_fp32_CMD=$(cat $config_file | grep CMD | grep deeprec_fp32 | awk -F ":" '{print$2}')
tf_fp32_CMD=$(cat $config_file | grep CMD | grep tf_fp32 | awk -F ":" '{print$2}')


# 从配置文件读取cpu限制
cpus=$(cat $config_file | grep cpus | awk -F " " '{print $2}')
if [  -z $cpus ];then
    cpu_set=""
else
    cpu_set="--cpuset-cpus $cpus"

fi

# 从配置文件读取测试环境变量配置
env_var=$(cat $config_file |grep export)


# 创建目录
if [ ! -d "./benchmark_result/record/script/$currentTime/" ];then
    mkdir -p ./benchmark_result/record/script/$currentTime/
fi

if [ ! -d $gol_dir$currentTime ];then
    mkdir -p "$gol_dir$currentTime" 
fi 
if [ ! -d $pointcheck_dir$currentTime ];then
    mkdir -p "$pointcheck_dir$currentTime"
fi

make_script\
&& checkEnv\
&& runContainers\
&& python3 ./gstep_count.py --log_dir=$gol_dir$currentTime
