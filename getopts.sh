#!/bin/bash
while getopts a:b: OPTION
do
  case $OPTION in
    a) echo "Option:A $OPTARG"
    ;;
    b) echo "Option:B $OPTARG"
    ;;
    ?) echo 'Invalid Option' >&2
       exit 1
       USAGE
    ;;
  esac
shift "$(( OPTIND -1 ))"
if [[ "${#}" -lt 1 ]]
then
        echo "Please enter atleast one argumnet"
        exit 1
fi
echo "Reaminng Arguments apart from Options ${@}"
done
