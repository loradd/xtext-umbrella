#!/bin/bash

if [ -z "$1" ]; then
    echo "Please provide a version"
    exit -1
else
    echo "Set version: $1"
    VERSION=$1
fi


