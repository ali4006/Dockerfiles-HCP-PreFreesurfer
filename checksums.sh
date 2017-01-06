#!/bin/bash

set -u
set -e

function die {
    echo -e $*
    # will exit the script since the error flag is set
    return 1
}

if [ $# != 1 ]
then
    die "Usage: $0 <subject_folder> \n Input the subject folder name."
fi

SUBJECT_FOLDER=$1
QSUB_FILE=".qsub.out.*"

count=`ls -a 2>/dev/null | grep $QSUB_FILE | wc -l`
if [ $count != 0 ]
then
    echo "###########################################"
    echo "############ Checksum of docker image #####"
    echo "###########################################"
    grep "Digest: sha256:" $QSUB_FILE
fi

echo "*******************************************"
echo "************ Checksum of files ************"
echo "*******************************************"

find ${SUBJECT_FOLDER} -type f | sort | xargs md5sum
