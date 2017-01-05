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

echo "###########################################"
echo "############ Checksum of docker image #####"
echo "###########################################"

grep "Digest: sha256:" .qsub.out.*

echo "*******************************************"
echo "************ Checksum of files ************"
echo "*******************************************"

find ${SUBJECT_FOLDER} -type f | sort | xargs md5sum



