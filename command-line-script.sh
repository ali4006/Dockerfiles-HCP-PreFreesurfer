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

if [ $# != 2 ]
then
  die ${INITDIR} "Needs 2 arguments. Usage: $0 <subject_folder> <name>"
fi

SUBJECT_FOLDER=$1
NAME=$2

EXECUTION_DIR=exec
BEFORE_FILE=${EXECUTION_DIR}/${SUBJECT_FOLDER}/checksums-before.txt
AFTER_FILE=${EXECUTION_DIR}/${SUBJECT_FOLDER}/checksums-after.txt

create-execution-dir.sh ${SUBJECT_FOLDER} ${EXECUTION_DIR}                               || die ${INITDIR} "Cannot create execution directory."
checksums.sh ${SUBJECT_FOLDER} &> ${BEFORE_FILE}                                         || die ${INITDIR} "Checksum script failed."
monitor.sh &> ${EXECUTION_DIR}/${SUBJECT_FOLDER}/monitor.txt                             || die ${INITDIR} "Monitoring script failed."
cd ${EXECUTION_DIR}                                                                      || die ${INITDIR} "Cannot cd to ${EXECUTION_DIR}."
PreFreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER} --runlocal || die ${INITDIR} "Pipeline failed."
cd ${INITDIR}                                                                            || die ${INITDIR} "cd .. failed."
checksums.sh ${SUBJECT_FOLDER} &> ${AFTER_FILE}                                          || die ${INITDIR} "Checksum script failed."

ln -s ${EXECUTION_DIR}/${SUBJECT_FOLDER} ${SUBJECT_FOLDER}-${NAME}                       || die ${INITDIR} "Cannot link results."

