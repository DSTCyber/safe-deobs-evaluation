#!/bin/bash

if [ "$#" == "0" ]; then
    echo "Usage: $0 /path/to/output/dir"
    exit 1
fi

THIS_DIR="$(dirname $(realpath -s $0))"
OUTPUT_DIR="$1"

export SAFE_HOME

source "${THIS_DIR}/deobfuscate.sh"
deduplicate ${OUTPUT_DIR}
