#!/bin/bash

set -u
set -e

function die {
    echo -e $*
    # will exit the script since the error flag is set
    return 1
}

if [ $# != 3 ]
then
    die "Usage: $0 <subject_folder> <subject_folder_original_number> <execution_folder>\n Folders have to be in the current working folder."
fi

subjectDir=$1
test -d ./${subjectDir} || die "${subjectDir} is not a directory or it is not in the current working folder."

#To get the original HCP subject name
subjectId=$2

execFolder=$3

# create new directory
mkdir -p ${execFolder}

# copy the subject directory
cp -R ${subjectDir}/ ${execFolder} || die "Cannot cp ${subjectDir} to ${execFolder}"

#Rename the subjectDir to subjectId
mv ${execFolder}/${subjectDir} ${execFolder}/${subjectId} || die "Cannot mv ${subjectDir} to ${subjectId}"


