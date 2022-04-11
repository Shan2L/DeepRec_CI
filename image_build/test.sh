    FROM cesg-prc-registry.cn-beijing.cr.aliyuncs.com/cesg-ali/deeprec:tf

ENV export http_proxy http://child-prc.intel.com:913
ENV export https_proxy http://child-prc.intel.com:913

RUN mkdir /home/build
WORKDIR /home/build
RUN wget https://deeprec-whl.oss-cn-beijing.aliyuncs.com/tensorflow-1.15.5%2Bdeeprec2201-220408%2B701d5fd-cp36-cp36m-linux_x86_64.whl
RUN pip install tensorflow-1.15.5%2Bdeeprec2201-220408%2B701d5fd-cp36-cp36m-linux_x86_64.whl
    EOF
    
