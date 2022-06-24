function choose_task()
{
    [[ $deeprec == true ]] && modify_dockerfile $deeprec_base_img deeprec      
    [[ $modelzoo == true ]] && modify_dockerfile $modelzoo_base_img deeprec-modelzoo
}


function modify_dockerfile()
{
    base_image=$1
    tag=$2

    eval "cat<<EOF
$(< $dockerfile_template)
EOF
"> $record_dir/$currentTime/${tag}_DOCKERFILE
}


function build_image_by_dockerfile()
{
    dockerfile=$1
    prefix=$2
    catg=$(echo $dockerfile | awk -F "-" '{print $1}')
    cd $record_dir/$currentTime/
    sudo docker build -t  $2:$whl_date_tag-$whl_hash_tag-$image_tag  -f $dockerfile .
    sudo docker push  $2:$whl_date_tag-$whl_hash_tag-$image_tag
}


function main()
{
    mkdir -p $record_dir/$currentTime
    choose_task
    build_image_by_dockerfile deeprec_DOCKERFILE $deeprec_img_prefix
    build_image_by_dockerfile deeprec-modelzoo_DOCKERFILE $modelzoo_img_prefix
}

image_tag=$1
deeprec=$2
modelzoo=$3

currentTime=`date "+%Y-%m-%d-%H-%M-%S"`
config_file='./config.yml'
record_dir=$(cd ./record/ && pwd)
home_path=$(pwd)
dockerfile_template=$home_path/DOCKERFILE
whl_address=$(cat $config_file | shyaml get-value whl_address)
whl_file=$(echo $whl_address | awk -F '/' '{print $4}'|sed 's/%2B/+/g')
#whl_date_tag=$(echo $whl_address | awk -F "-" '{print $6}' | awk -F "%2B" '{print $1}')
whl_date_tag=$(echo $currentTime|sed 's/-//g' | cut -c 3-8)
whl_hash_tag=$(echo $whl_address | awk -F "-" '{print $6}' | awk -F "%2B" '{print $2}')
deeprec_base_img=$(cat $config_file | shyaml get-value deeprec_base_img)
modelzoo_base_img=$(cat $config_file | shyaml get-value modelzoo_base_img)
deeprec_img_prefix=$(echo $deeprec_base_img | awk -F ":" '{print $1}')
modelzoo_img_prefix=$(echo $modelzoo_base_img | awk -F ":" '{print $1}')
main

