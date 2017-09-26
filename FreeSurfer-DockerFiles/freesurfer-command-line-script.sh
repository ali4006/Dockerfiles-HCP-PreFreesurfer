#!/bin/bash

function die {
    # die $DIR Error message
    local DIR=$1
    shift
    local D=`date`
    echo "[ ERROR ] [ $D ] $*"
    exit 1
}

INITDIR=$PWD

if [ $# -lt 3 ]; then
  die ${INITDIR} "Needs 3 arguments and an optional flag. If you keep -r flag as an input, then the reprozip trace process is triggered . Usage: $0 [-r] <subject_folder> <name> <path/to/the/license/text>"
fi

REPROZIP_FLAG=false
#If reprozip flag is set
if [ $# -eq 4 ]; then
  if [ $1 = "-r" ]; then 
    REPROZIP_FLAG=true
    SUBJECT_FOLDER=$2
    NAME=$3
    LICENSE=$4
  fi
else
  SUBJECT_FOLDER=$1
  NAME=$2
  LICENSE=$3
fi

EXECUTION_DIR=exec

#To maintain the same subject folder name while processing we are taking only the subject folder name
SUBJECT_FOLDER_ORIGINAL_NUMBER="$(echo "$1" | awk -F"-" '{print $1}')"


BEFORE_FILE=${EXECUTION_DIR}/${SUBJECT_FOLDER_ORIGINAL_NUMBER}/checksums-before.txt
AFTER_FILE=${EXECUTION_DIR}/${SUBJECT_FOLDER_ORIGINAL_NUMBER}/checksums-after.txt

create-execution-dir.sh ${SUBJECT_FOLDER} ${SUBJECT_FOLDER_ORIGINAL_NUMBER} ${EXECUTION_DIR}              || die ${INITDIR} "Cannot create execution directory."
checksums.sh ${EXECUTION_DIR}/${SUBJECT_FOLDER_ORIGINAL_NUMBER}  > ${BEFORE_FILE}                        		  || die ${INITDIR} "Checksum script failed."
monitor.sh &> ${EXECUTION_DIR}/${SUBJECT_FOLDER_ORIGINAL_NUMBER}/monitor.txt                             		  || die ${INITDIR} "Monitoring script failed."

#Move the license file to the freesurfer directory
if [ ! -z "${LICENSE}" ];then
  \cp ${LICENSE} ${FREESURFER_HOME}/
fi

cd ${EXECUTION_DIR}                                                                      		  || die ${INITDIR} "Cannot cd to ${EXECUTION_DIR}."

#Adding the reprozip command to trace the processing of subjects
if [ ${REPROZIP_FLAG} = true ]; then
  source ${FREESURFER_HOME}/SetUpFreeSurfer.sh
  reprozip trace FreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER_ORIGINAL_NUMBER} --runlocal || die ${INITDIR} "Pipeline failed."
else
  source ${FREESURFER_HOME}/SetUpFreeSurfer.sh
  FreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER_ORIGINAL_NUMBER} --runlocal                || die ${INITDIR} "Pipeline failed."
fi

cd ${INITDIR}                                                                            		               || die ${INITDIR} "cd .. failed."
checksums.sh ${EXECUTION_DIR}/${SUBJECT_FOLDER_ORIGINAL_NUMBER} > ${AFTER_FILE}                          	       || die ${INITDIR} "Checksum script failed."

#Copying the .reprozip-trace folder in execution directory to the subject folder.
if [ ${REPROZIP_FLAG} = true ]; then
  cp -r ${EXECUTION_DIR}/.reprozip-trace ${EXECUTION_DIR}/${SUBJECT_FOLDER_ORIGINAL_NUMBER}
fi

ln -s ${EXECUTION_DIR}/${SUBJECT_FOLDER_ORIGINAL_NUMBER} ${SUBJECT_FOLDER}-${NAME}                       		  || die ${INITDIR} "Cannot link results."
