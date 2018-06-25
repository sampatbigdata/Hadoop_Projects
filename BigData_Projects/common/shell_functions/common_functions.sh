#!/bin/bash


# Convert the Input string to lower case
function convertToLowerCase() {
    OUTPUT_STRING=`echo $1 | tr '[:upper:]' '[:lower:]'`
    echo $OUTPUT_STRING
}

# Convert the Input string to UPPER case
function convertToUpperCase() {
    OUTPUT_STRING=`echo $1 | tr '[:lower:]' '[:upper:]'`
    echo $OUTPUT_STRING
}

function echoCommand() {
    echo "Executing Command : $1"
}

function execute() {
    evalString1="$1"
    echo -e "Executing Command : $evalString1" | sed 's/ \+ /\t/g' | tr "\t" "\n" |sed "/^$/d"| sed ':a;N;$!ba;s/\n/\n\t\t         /g'
    eval $1
}
#For information
function info() {
    echo -e "[INFO] $1"
}

#For Error
function error() {
    echo -e "[ERROR] $1"
}

#For Error
function warn() {
    echo -e "[WARN] $1"
}

#Current date time
function getFormattedCurrentDate() {
    current_timestamp="`date +"%Y-%m-%d %H:%M:%S"`";
    echo ${current_timestamp}
}

function getFormattedDate() {
    formattedDate=$(date -d $1 +"%Y%m%d")
    echo ${formattedDate}
}

#Read Parameters From Azkaban
function readParameters() {
    info "Parsing args ..."
    for item in "$@"; do
        case $item in
        (*=*) eval $item;;
        esac
    done
    info "Done parsing args ..!!!"
}

#Checks the exit status
function validateExitStatus() {
    if [ $1 -eq 0 ];
    then
        info "$2";
    else
        error "$3";
        exit 100;
    fi
}

# Exit function to be called if variable is not set by printing the variable name
function variablesNotSetExit() {
    NOT_SET_VARIABLE_NAME=$1
    error "$NOT_SET_VARIABLE_NAME is not set. Validate the options."
    exit 1;
}

# Check if the given variable is set or not
function checkVariableIfSet() {
    VARIABLE_NAME=$1
    VARIABLE_VALUE=$2
    if [ ! -z "$VARIABLE_VALUE" ]; then
        info "$VARIABLE_NAME set to $VARIABLE_VALUE"
    else
        variablesNotSetExit $VARIABLE_NAME
fi
}

function checkVariableIfSetCondition() {
    VARIABLE_VALUE=$1
    if [ ! -z "$VARIABLE_VALUE" ]; then
        return 0
    else
        return 1
    fi
}

# Check exit code of the command
function checkAndLogExistStatus() {
    MESSAGE=$1
    RETURN_CODE=$2
    if [ $RETURN_CODE -eq 0 ]
    then
        info "$MESSAGE successful"
    else
        error "$MESSAGE failed"
        exit $RETURN_CODE
    fi
}


# Load configuration from file
function loadConfigsFromFile() {
    CONFIG_FILE_PATH=$1
    if checkFileExist $CONFIG_FILE_PATH;then
    . $CONFIG_FILE_PATH
        info "Successfully loaded $CONFIG_FILE_PATH"
    else
        warning "$CONFIG_FILE_PATH does not exist. Switching to use defaults."
    fi
}

function replaceDotWithUnderscore() {
    INPUT_STRING=$1
    OUTPUT_STRING=`echo $1 | sed 's/\./_/g'`
    echo $OUTPUT_STRING
}

function getYearFromDate () {
    YEAR=`echo $1|cut -d'-' -f 1`
    echo $YEAR
}

function getMonthFromDate () {
    MONTH=`echo $1|cut -d'-' -f 2`
    echo $MONTH
}

function getDayFromDate() {
    DAY=`echo $1|cut -d'-' -f 3`
    echo $DAY
}

function getYearMonthDayFromDate () {
    #PASSED_DATE=$1;
    export $2=`getYearFromDate $1`
    export $3=`getMonthFromDate $1`
    export $4=`getDayFromDate $1`

}

function createLogDirIfNotExists(){

    TABLE_NAME=$1
    checkVariableIfSet "BASE_LOG_DIR" "${BASE_LOG_DIR}"

    if [ ! -d "${BASE_LOG_DIR}/${TABLE_NAME}" ]; then

        mkdir -p ${BASE_LOG_DIR}
        exit_code=$?
        success_message="Created log directory ${BASE_LOG_DIR}"
        failure_message="Failed to create log directory ${BASE_LOG_DIR}"

        validateExitStatus "${exit_code}" "${success_message}" "${failure_message}"
    fi

}


#########################################Sample Pig Run Command With Properties#######################################
#                                                                                                                    #
#     pig -Dpig.additional.jars=/home/cloudera/Desktop/Spark-Kafka-UseCase/BigData_Projects-1.0-SNAPSHOT_java7.jar \ #
#         -Dudf.import.list=com.airline.project.pigudf  \                                                            #
#         -Dmapreduce.job.queuename=default \                                                                        #
#         -Djob.name="TestPig" \                                                                                     #
#         -f /home/cloudera/test.pig                                                                                 #
#                                                                                                                    #
######################################################################################################################

function executePig(){

  ### Fetching pig script name from the arguments
  local index
  for (( i=1; i<=$#; i++ )); do
    if [ "${!i}" == "-f" ]; then
      index="${i}"
    fi
  done
  index=$((index + 1))
  eval PIG_FILE_NAME=\${$index}
  LOG_FILE_NAME=`basename ${PIG_FILE_NAME} | cut -d'.' -f1`
  info "[LOG_FILE_NAME] ${LOG_FILE_NAME}"
  ### End of fetching pig script name from arguments

  checkVariableIfSet "LOG_FILE_NAME" "${LOG_FILE_NAME}"

  current_timestamp=`date +'%Y%m%d%H%M%S'`
  type="pig"
  log_file="${BASE_LOG_DIR}/${LOG_FILE_NAME}/${type}_${LOG_FILE_NAME}_${current_timestamp}.log"
  out_file="${BASE_LOG_DIR}/${LOG_FILE_NAME}/${type}_${LOG_FILE_NAME}_${current_timestamp}.out"

  info "Log file : ${log_file}"
  info "Out file : ${out_file}"

  user_namespace_param_file=$(getNamespaceFileForCurrentUser)
  user_namespace_param_file_option="${ENV_HOME}/namespace/${user_namespace_param_file}"

  #Assigning default mapreduce job queuename if queue name is empty
  if [ -z "${MAPREDUCE_JOB_QUEUENAME}" ]; then
    MAPREDUCE_JOB_QUEUENAME="default"
  fi

  COMMAND=`echo "pig -Dudf.import.list="${PIG_UDF_IMPORT_LIST}"  \
      -Dpig.additional.jars="${EXTERNAL_JARS}" \
      -Dmapreduce.job.queuename="${MAPREDUCE_JOB_QUEUENAME}" \
      -Djob.name="${JOB_NAME}" \
      -useHCatalog \
      -logfile "${log_file}" \
      -m "${user_namespace_param_file_option}" \
      -m "${ENV_HOME}/namespace/${user_namespace_param_file}" \
      -m "${ENV_HOME}/namespace/default.pig.properties" \
      "$@" 2>&1 | tee "${out_file}"" | sed 's/  */ /g'`

  echoCommand "${COMMAND}"

  pig -Dudf.import.list="${PIG_UDF_IMPORT_LIST}"  \
      -Dpig.additional.jars="${EXTERNAL_JARS}" \
      -Dmapreduce.job.queuename="${MAPREDUCE_JOB_QUEUENAME}" \
      -Djob.name="${JOB_NAME}" \
      -useHCatalog \
      -logfile "${log_file}" \
      -m "${user_namespace_param_file_option}" \
      -m "${ENV_HOME}/namespace/${user_namespace_param_file}" \
      -m "${ENV_HOME}/namespace/default.pig.properties" \
      "$@" 2>&1 | tee "${out_file}"

  exit_code=${PIPESTATUS[0]}
  return ${exit_code}

}