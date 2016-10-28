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
    die "Usage: $0 <subject_folder> <new_subjec_folder> \n Folders have to be in the current working folder."
fi

subjectDir=$1
test -d ./${subjectDir} || die "${subjectDir} is not a directory or it is not in the current working folder."

# create new directory
newDir=$2
mkdir ${newDir}
test -d ${newDir} || die "Cannot create new directory ${newDir}"

# link content of old directory in new directory
for dirent in `ls ${subjectDir}`
do
    ln -s ${PWD}/${subjectDir}/${dirent} ${newDir}/${dirent}
    test -e ${newDir}/${dirent} || die "Invalid file: ${newDir}/${dirent}"
done

# print new directory
echo ${newDir}
