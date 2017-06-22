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

if [ $# -lt 2 ]; then
  die ${INITDIR} "Needs 2 arguments and an optional flag. If you keep -r flag as an input, then the reprozip trace process is triggered . \n
		  If you keep the -prefs flag, then PreFreeSurfer script is executed. \n
		  If you keep the -fs flag, Freesurfer script is executed. Along with the [-fs] flag a license file should be input as the next parameter.\n
		  If you keep the -pfs flag, PostFreeSurfer script is executed. \n
		  If no optional flags are kept, then PreFreeSurfer script gets executed. \n
		  Usage: $0 [-r] <subject_folder> <name> [-fs] /path/to/license/file or $0 [-r] <subject_folder> <name> [-pfs] or  $0 [-r] <subject_folder> <name> [-prefs] "
fi

REPROZIP_FLAG=false
#If reprozip flag is set
#Only case in which the number of input parameters is 5 is when reprozip flag is set along 
#with FreeSurfer Script and path to the license file
if [ $# -eq 5 ]; then
  if [ $1 = "-r" ]; then 
    REPROZIP_FLAG=true
    SUBJECT_FOLDER=$2
    NAME=$3
    SCRIPT=$4
    LICENSE=$5
  fi
#In case of 4 input parameters, it can either be reprozip flag with prefreesurfer or postfreesurfer
#or in case of freesurfer, the license file without the reprozip flag.
elif [ $# -eq 4 ]; then
  if [ $1 = "-r" ]; then        
    REPROZIP_FLAG=true
    SUBJECT_FOLDER=$2
    NAME=$3
    SCRIPT=$4
  else
    SUBJECT_FOLDER=$1
    NAME=$2
    SCRIPT=$3
    LICENSE=$4
  fi
#Otherwise it would be the working directory, subject and flags for prefreesurfer or postfreesurfer.
else
  SUBJECT_FOLDER=$1
  NAME=$2
  #Making sure that the script is not freesurfer without a license file.
  if [ $3 != "-fs" ];then
    SCRIPT=$3
  else
    die ${INITDIR} "Freesurfer flag should be followed by a path to the license file as the next parameter"
  fi
fi

EXECUTION_DIR=exec
BEFORE_FILE=${EXECUTION_DIR}/${SUBJECT_FOLDER}/checksums-before.txt
AFTER_FILE=${EXECUTION_DIR}/${SUBJECT_FOLDER}/checksums-after.txt

create-execution-dir.sh ${SUBJECT_FOLDER} ${EXECUTION_DIR}                               		  || die ${INITDIR} "Cannot create execution directory."
checksums.sh ${EXECUTION_DIR}/${SUBJECT_FOLDER}  > ${BEFORE_FILE}                        		  || die ${INITDIR} "Checksum script failed."
monitor.sh &> ${EXECUTION_DIR}/${SUBJECT_FOLDER}/monitor.txt                             		  || die ${INITDIR} "Monitoring script failed."
cd ${EXECUTION_DIR}                                                                      		  || die ${INITDIR} "Cannot cd to ${EXECUTION_DIR}."

#Adding the reprozip command to trace the processing of subjects
if [ ${REPROZIP_FLAG} = true && ${SCRIPT}="-prefs" ]; then
  reprozip trace PreFreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER} --runlocal || die ${INITDIR} "PreFreeSurfer Pipeline failed."
elif [ ${SCRIPT} = "-fs" && ${REPROZIP_FLAG} = true ];then
  mv ${LICENSE} ${FREESURFER_HOME}/
  source ${FREESURFER_HOME}/SetUpFreeSurfer.sh
  reprozip trace FreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER} --runlocal    || die ${INITDIR} "FreeSurfer Pipeline failed."
elif  [ ${SCRIPT} = "-fs" ];then
  mv ${LICENSE} ${FREESURFER_HOME}/
  source ${FREESURFER_HOME}/SetUpFreeSurfer.sh
  FreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER} --runlocal                   || die ${INITDIR} "FreeSurfer Pipeline failed."
elif [ ${SCRIPT} = "-pfs" && ${REPROZIP_FLAG} = true ];then
  reprozip trace PostFreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER} --runlocal|| die ${INITDIR} "PostFreeSurfer Pipeline failed."
elif [ ${SCRIPT} = "-pfs" ];then
  PostFreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER} --runlocal               || die ${INITDIR} "PostFreeSurfer Pipeline failed."
else
  PreFreeSurferPipelineBatch.sh --StudyFolder=$PWD --Subjlist=${SUBJECT_FOLDER} --runlocal                || die ${INITDIR} "PreFreeSurfer Pipeline failed."
fi

cd ${INITDIR}                                                                            		  || die ${INITDIR} "cd .. failed."
checksums.sh ${EXECUTION_DIR}/${SUBJECT_FOLDER} > ${AFTER_FILE}                          		  || die ${INITDIR} "Checksum script failed."

#Copying the .reprozip-trace folder in execution directory to the subject folder.
if [ ${REPROZIP_FLAG} = true ]; then
  cp -r ${EXECUTION_DIR}/.reprozip-trace ${EXECUTION_DIR}/${SUBJECT_FOLDER}
fi

ln -s ${EXECUTION_DIR}/${SUBJECT_FOLDER} ${SUBJECT_FOLDER}-${NAME}                       		  || die ${INITDIR} "Cannot link results."

