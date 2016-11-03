#!/bin/bash

set -u
set -e

function die {
    echo -e $*
    # will exit the script since the error flag is set
    return 1
}

if [ $# != 2 ]
then
    die "Usage: $0 <subject_folder> <execution_folder>\n Folders have to be in the current working folder."
fi

subjectDir=$1
test -d ./${subjectDir} || die "${subjectDir} is not a directory or it is not in the current working folder."

execfolder=$2
# create new directory
mkdir -p ${execFolder}/${subjectDir}

# link content of old directory in new directory
for dirent in `ls ${subjectDir}`
do
    ln -s ${PWD}/${subjectDir}/${dirent} ${execFolder}/${subjectDir}/${dirent}
    test -e ${execFolder}/${subjectDir}/${dirent} || die "Invalid file: exec/${subjectDir}/${dirent}"
done

