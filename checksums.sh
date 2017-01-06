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

echo "###########################################"
echo "############ Checksum of docker image #####"
echo "###########################################"

(ls ${QSUB_FILE} && grep "Digest: sha256:" ${QSUB_FILE}) || (die ${SUBJECT_FOLDER} "Cannot find sha256 digest of docker image")

echo "*******************************************"
echo "************ Checksum of files ************"
echo "*******************************************"

find ${SUBJECT_FOLDER} -type f | sort | xargs md5sum

