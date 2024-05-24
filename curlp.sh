#!/bin/bash

while getopts "d:" opt; do
  case $opt in
    d)
      BODY=$OPTARG
      ;;
  esac
done

shift $((OPTIND-1))

if [ -z "$DATA" ]; then
  read -p "Body: " BODY
fi

curl -X POST -d "$BODY" -H "Content-type: application/json" $1
