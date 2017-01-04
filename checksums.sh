#!/bin/bash

set -u
set -e

echo "###########################################"
echo "############ Checksum of docker image #####"
echo "###########################################"

grep "Digest: sha256:" *.qsub.out

echo "*******************************************"
echo "************ Checksum of files ************"
echo "*******************************************"

find . -type f | sort | xargs md5sum



