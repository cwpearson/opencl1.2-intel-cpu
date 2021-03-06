FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

ENV OCL_INC /opt/khronos/opencl/include
ENV OCL_LIB /opt/intel/opencl-1.2-6.4.0.25/lib64

RUN apt-get update -q && apt-get install --no-install-recommends -yq alien wget clinfo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download the Khronos OpenCL 1.20 headers
RUN export TGT_DIR="$OCL_INC" \
    && export URL="https://raw.githubusercontent.com/KhronosGroup/OpenCL-Headers/opencl12" \
    && mkdir -p "$TGT_DIR/CL" && cd "$TGT_DIR/CL" \
    && for u in opencl cl_platform cl cl_ext cl_gl cl_gl_ext; do \
         wget -q --no-check-certificate $URL/$u.h; \
       done;

# Download the Intel OpenCL CPU runtime and convert to .deb packages
RUN export RUNTIME_URL="http://registrationcenter-download.intel.com/akdlm/irc_nas/9019/opencl_runtime_16.1.1_x64_ubuntu_6.4.0.25.tgz" \
    && export TAR=$(basename ${RUNTIME_URL}) \
    && export DIR=$(basename ${RUNTIME_URL} .tgz) \
    && wget -q ${RUNTIME_URL} \
    && tar -xf ${TAR} \
    && for i in ${DIR}/rpm/*.rpm; do alien --to-deb $i; done \
    && rm -rf ${DIR} ${TAR} \
    && dpkg -i *.deb \
    && rm *.deb

RUN mkdir -p /etc/OpenCL/vendors/ \
    && echo "$OCL_LIB/libintelocl.so" > /etc/OpenCL/vendors/intel.icd

# Let the system know where the OpenCL library can be found at load time.
ENV LD_LIBRARY_PATH $OCL_LIB:$LD_LIBRARY_PATH
