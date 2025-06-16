#!/bin/bash
LENGHT=48
USAGE (){

        echo "usage: $0 [-vs] [-l LENGHT]"
        echo "-v    Verbosity"
        echo "-s    Append a special character"
        echo "-l    LENGHT speacify password lenght"
        exit 1
}
LOG (){
        local MESSAGE="${@}"
        if [[ "${VERBOSE}" = "true" ]]
        then
                echo "${MESSAGE}"
        fi
}
while getopts vsl: OPTION
do
  case $OPTION in
    v) VERBOSE='true'
       echo "Verbose is on"
    ;;
    s) SPECIALCHAR='true'
    ;;
    l) LENGHT="${OPTARG}"
    ;;
    ?) USAGE
    ;;
  esac
done
echo "Number of Argumnets: $#"
if [[ $# -lt 1 ]]
then
        USAGE
fi
TEST="Testing"
LOG "Generating Password $TEST"
PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c${LENGHT})
## APPend the special characheter
if [[ "${SPECIALCHAR}" == "true" ]]
then
        LOG 'selecting a random special character'
        SPCLCHAR=$(echo '@!#%&*()-+=' | fold -s1 | shuf | head -c1)
        PASSWORD="${PASSWORD}${SPCLCHAR}"
fi

LOG 'Here is the password'
echo "${PASSWORD}"
exit 0
