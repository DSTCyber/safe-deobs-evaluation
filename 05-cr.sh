#!/bin/bash

if [ "$#" == "0" ]; then
    echo "Usage: $0 /path/to/output/dir"
    exit 1
fi

THIS_DIR="$(dirname $(realpath -s $0))"
OUTPUT_DIR="$1"

if [ ! -d "${OUTPUT_DIR}/node_modules" ]; then
    pushd ${THIS_DIR}
    cd ${OUTPUT_DIR}
    npm install complexity-report
    popd
fi

export PATH="${OUTPUT_DIR}/node_modules/.bin":"${PATH}"

source "${THIS_DIR}/deobfuscate.sh"
complexity_report ${OUTPUT_DIR} "deduplicate"
complexity_report ${OUTPUT_DIR} "deobfuscate"
