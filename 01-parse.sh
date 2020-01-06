#!/bin/bash

if [ "$#" == "0" ]; then
    echo "Usage: $0 /path/to/output/dir"
    exit 1
fi

THIS_DIR="$(dirname $(realpath -s $0))"
OUTPUT_DIR="$1"

if [ ! -d "${OUTPUT_DIR}/node_modules/complexity-report" ]; then
    pushd ${THIS_DIR}
    cd ${OUTPUT_DIR}
    npm install complexity-report
    popd
fi

export PATH="${OUTPUT_DIR}/node_modules/.bin":"${PATH}"

source "${THIS_DIR}/deobfuscate.sh"
parse ${OUTPUT_DIR} ${MALWARE_DIR}
