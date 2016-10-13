# CentOS with FSL.
# Build via: docker build -f ./Dockerfile -t centos6-fsl-5 .
FROM centos:centos6
MAINTAINER laletscaria@yahoo.co.in

# Update the image with the latest packages 
RUN yum update -y && yum install -y \
    bc \
    git \
    tar \
    wget

# Permit access to fsl installation script (must exist locally)
ADD ./myFslInstallerScript.sh /myFslInstallerScript.sh


ENV SHELL /bin/bash

# Install fsl to default dir
RUN echo -e "/usr/local/src" | ./myFslInstallerScript.sh

#Clone HCP pipelines
RUN git clone https://github.com/Washington-University/Pipelines.git pipelines;cp -r pipelines /usr/local/src/;rm -rf pipelines;

# Set environment variables (run export not needed)
ENV FSLDIR=/usr/local/src/fsl
ENV PATH=${FSLDIR}/bin:${PATH}
ENV HCPPIPEDIR=/usr/local/src/pipelines/PreFreeSurfer
# FSL environment variables
ENV FSLOUTPUTTYPE=NIFTI_GZ FSLTCLSH=$FSLDIR/bin/fsltclsh FSLWISH=$FSLDIR/bin/fslwish FSLGECUDAQ=cuda.q
# HCP environment variables
ENV HCPPIPEDIR_PreFS=$HCPPIPEDIR/PreFreeSurferPipeline.sh HCPPIPEDIR_Global=$HCPPIPEDIR/scripts
