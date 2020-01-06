#!/bin/bash

if [ "$#" == "0" ]; then
    echo "Usage: $0 /path/to/output/dir"
    exit 1
fi

THIS_DIR="$(dirname $(realpath -s $0))"
OUTPUT_DIR="$1"

source "${THIS_DIR}/deobfuscate.sh"
normalize ${OUTPUT_DIR} 3600
