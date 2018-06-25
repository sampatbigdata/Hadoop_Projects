#!/usr/bin/env bash
####################################################################
# AUTHOR : SAMPAT BUDANKAYALA                                      #
# DESC : THIS SCRIPT POPULATES THE AIRLINE DATA AND STORE IN AVRO  #
# CREATE DATE :                                                    #
# MODIFIED DATE :                                                  #
# MODIFIED DESC :                                                  #
####################################################################


# Extract SCRIPT_HOME
SCRIPT_PATH="${BASH_SOURCE[0]}";
SCRIPT_HOME=`dirname $SCRIPT_PATH`

PROJECT_HOME=`dirname ${SCRIPT_HOME}`
COMMON_HOME="${PROJECT_HOME}/common"
ENV_HOME="${PROJECT_HOME}/etc"
PIG_HOME="${PROJECT_HOME}/pig"
DATALAKE_HOME="${PROJECT_HOME}/datalake"

export ENV_HOME;

# Load namespace property file

. ${COMMON_HOME}/shell_functions/namespace_functions.sh
. ${COMMON_HOME}/shell_functions/common_functions.sh

info "[COMMON_HOME_PATH] $COMMON_HOME"
SCRIPT_START_TIME=$(getFormattedCurrentDate)
info "[SCRIPT_START_TIME] $SCRIPT_START_TIME"
user_namespace_param_file=$(getNamespaceFileForCurrentUser)
info "[NAMESPACE_PROP_FILE_NAME] $user_namespace_param_file"

# Load default environmental property files
info "-------------SOURCE NAMESPACE PROPERTIES-----------------"
. ${ENV_HOME}/namespace/${user_namespace_param_file}
. ${ENV_HOME}/project/project.env.properties
. ${ENV_HOME}/project/project.pig.properties