
config_file="./config.yml"

r1=$(cat config.yml | grep -n whl_address | awk -F ':' '{print $1}')
r2=$(cat config.yml | grep -n deeprec_base_img | awk -F ':' '{print $1}')
r3=$(cat config.yml | grep -n modelzoo_base_img | awk -F ':' '{print $1}')
r4=$(cat config.yml | grep -n image_tag | awk -F ':' '{print $1}')


sed -i "${r1}c whl_address: $1" $config_file
sed -i "${r2}c deeprec_base_img: $2" $config_file
sed -i "${r2}c modelzoo_base_img: $3" $config_file
sed -i "${r2}c image_tag: $4" $config_file
