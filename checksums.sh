#!/bin/bash

set -u
set -e

SUBJECT_FOLDER=$1

echo "###########################################"
echo "############ Checksum of docker image #####"
echo "###########################################"

grep "Digest: sha256:" .qsub.out.*

echo "*******************************************"
echo "************ Checksum of files ************"
echo "*******************************************"

find ${SUBJECT_FOLDER} -type f | sort | xargs md5sum



