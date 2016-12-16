FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

# Install opencv, OpenCL 1.2 headers, and other things needed to build OpenCL code
RUN apt-get update -qq && apt-get install --no-install-recommends -yqq alien wget opencl-headers \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download the Intel OpenCL runtime and convert to .deb packages
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
    && echo "/opt/intel/opencl-1.2-6.4.0.25/lib64/libintelocl.so" > /etc/OpenCL/vendors/intel.icd

# Let the system know where the OpenCL library can be found at load time.
ENV LD_LIBRARY_PATH /opt/intel/opencl-1.2-6.4.0.25/lib64
