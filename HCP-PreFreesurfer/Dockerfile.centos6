# CentOS with FSL.
# Build via: docker build -f ./Dockerfile -t centos6-fsl-5 .
FROM centos:centos6
MAINTAINER laletscaria@yahoo.co.in

# Update the image with the latest packages
# Fix the version of GCC 
RUN yum update -y && yum install -y \
    bc \
    curl-devel \ 
    epel-release \
    expat-devel \
    freetype.x86_64 \
    gcc \
    gettext-devel \
    git \
    libfontconfig.x86_64 \
    libpng.x86_64 \
    libSM.x86_64 \
    libXrender.x86_64 \
    openssl-devel \
    perl-ExtUtils-MakeMaker \
    tar \
    unzip \
    wget \
    zlib-devel

RUN yum install -y \
    python-pip \
    python-devel

# Permit access to fsl installation script (must exist locally)
ADD ./myFslInstallerScript.sh /myFslInstallerScript.sh

# Install fsl to default dir
RUN echo -e "/usr/local/src" | ./myFslInstallerScript.sh

#Clone HCP pipelines
# Fix the version of pipelines 
RUN wget https://github.com/Washington-University/Pipelines/archive/v3.4.0.tar.gz -O pipelines.tar.gz; \
    tar zxvf /pipelines.tar.gz -C /usr/local/src/; \
    mv /usr/local/src/Pipelines-* /usr/local/src/pipelines; \
    rm -rf pipelines.tar.gz; \
    wget https://ftp.humanconnectome.org/workbench/workbench-rh_linux64-v1.2.3.zip -O workbench.zip; \
    unzip workbench.zip -d /usr/local/src/; \
    mv /usr/local/src/workbench/bin_rh_linux64 /usr/local/src/workbench/bin_linux64; \
    rm -rf workbench.zip;

# Set environment variables (run export not needed)
ENV FSLDIR=/usr/local/src/fsl \
    FSLOUTPUTTYPE=NIFTI_GZ \
    FSLGECUDAQ=cuda.q \
    CARET7DIR=/usr/local/src/workbench/

ENV PATH=${FSLDIR}/bin:${PATH} \
    FSLTCLSH=${FSLDIR}/bin/fsltclsh \
    FSLWISH=${FSLDIR}/bin/fslwish

# Post-installation tweaks for HCP pipelines (undocumented)

ENV HOME=/usr/local/src \
    PATH=${PATH}:/usr/local/src/pipelines/Examples/Scripts

#Fix numpy version and link pipelines folder
RUN mkdir /usr/local/src/projects; \
    ln -s /usr/local/src/pipelines /usr/local/src/projects/Pipelines; \
    pip install numpy;
