THIS_DIR="$(dirname $(realpath -s $0))"
SAFE_HOME="${THIS_DIR}/safe-deobs"
MALWARE_DIR="${THIS_DIR}/javascript-malware-collection"

export SAFE_HOME

function __parse() {
  local OUTPUT_DIR=$1
  local JS=$2

  cr ${JS} >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    cp ${JS} ${OUTPUT_DIR}
  fi
}

function parse() {
  local OUTPUT_DIR=$1
  local SAMPLE_DIR=$2
  mkdir -p "${OUTPUT_DIR}/parse"

  local NUM_SAMPLES=$(find "${SAMPLE_DIR}" -type f -name '*.js' | wc -l)
  echo -e "\e[36m[*]\e[0m Parsing ${NUM_SAMPLES} samples in ${SAMPLE_DIR}..."

  export -f __parse
  find "${SAMPLE_DIR}" -type f -name '*.js' |   \
      parallel __parse "${OUTPUT_DIR}/parse" {} >/dev/null 2>/dev/null

  local NUM_SAMPLES=$(find "${OUTPUT_DIR}/parse" -type f -name '*.js' | wc -l)
  echo -e "\e[32m[+]\e[0m Parsed ${NUM_SAMPLES} samples"
}

#
# Normalize dataset
#

function normalize() {
  local OUTPUT_DIR=$1
  local TIME=$2
  mkdir -p "${OUTPUT_DIR}/normalize"

  local NUM_MALWARE_SAMPLES=$(find "${OUTPUT_DIR}/parse" -type f -name '*.js' | wc -l)
  echo -e "\e[36m[*]\e[0m Normalizing ${NUM_MALWARE_SAMPLES} samples..."

  find "${OUTPUT_DIR}/parse" -type f -name '*.js' |                 \
      parallel timeout "${TIME}s" ${SAFE_HOME}/bin/safe astRewrite  \
          -astRewriter:silent                                       \
          -astRewriter:out=${OUTPUT_DIR}/normalize/{/}              \
          -astRewriter:disableWithRewriter                          \
          {} 1>/dev/null 2>${OUTPUT_DIR}/normalize.err

  local NUM_NORMALIZED=$(find "${OUTPUT_DIR}/normalize" -type f -name '*.js' | wc -l)
  echo -e "\e[32m[+]\e[0m Normalized ${NUM_NORMALIZED} files"
}

#
# Remove duplicates
#

function deduplicate() {
  local OUTPUT_DIR=$1
  mkdir -p "${OUTPUT_DIR}/deduplicate"

  local NUM_NORMALIZED=$(find "${OUTPUT_DIR}/normalize" -type f -name '*.js' | wc -l)
  echo -e "\e[36m[*]\e[0m Removing duplicates from ${NUM_NORMALIZED} samples..."

  find "${OUTPUT_DIR}/normalize" -maxdepth 1 -type f -name '*.js'   \
      -exec sha1sum {} + | sort | uniq --check-chars=40 |           \
      cut -d' ' -f 3 | parallel cp {} "${OUTPUT_DIR}/deduplicate"   \
      1>/dev/null 2>${OUTPUT_DIR}/deduplicate.err

  local NUM_DEDUP=$(find "${OUTPUT_DIR}/deduplicate" -type f -name '*.js' | wc -l)
  echo -e "\e[32m[+]\e[0m ${NUM_DEDUP} deduplicated files"
}

#
# Deobfuscate
#

function deobfuscate() {
  local OUTPUT_DIR=$1
  local TIME=$2
  mkdir -p "${OUTPUT_DIR}/deobfuscate"

  local NUM_DEDUP=$(find "${OUTPUT_DIR}/deduplicate" -type f -name '*.js' | wc -l)
  echo -e "\e[36m[*]\e[0m Deobfuscating ${NUM_DEDUP} samples..."

  find "${OUTPUT_DIR}/deduplicate" -maxdepth 1 -type f -name '*.js' |   \
      parallel timeout "${TIME}s" ${SAFE_HOME}/bin/safe deobfuscate     \
          -astRewriter:disableWithRewriter                              \
          -deobfuscator:out=${OUTPUT_DIR}/deobfuscate/{/}               \
          {} 1>/dev/null 2>${OUTPUT_DIR}/deobfuscate.err

  local NUM_DEOBS=$(find "${OUTPUT_DIR}/deobfuscate" -type f -name '*.js' | wc -l)
  echo -e "\e[32m[+]\e[0m ${NUM_DEOBS} deobfuscated files"
}

#
# Complexity report
#

function complexity_report() {
  local OUTPUT_DIR=$1
  local TARGET_DIR=$2
  mkdir -p "${OUTPUT_DIR}/${TARGET_DIR}"

  local NUM_SAMPLES=$(find "${OUTPUT_DIR}/${TARGET_DIR}" -type f -name '*.js' | wc -l)
  echo -e "\e[36m[*]\e[0m Generating complexity report for ${NUM_SAMPLES} samples in ${TARGET_DIR}..."

  find "${OUTPUT_DIR}/${TARGET_DIR}" -type f -name '*.js' |             \
      parallel cr -f json -o ${OUTPUT_DIR}/${TARGET_DIR}/{/.}.json {}   \
      1>/dev/null 2>${OUTPUT_DIR}/${TARGET_DIR}_cr.err

  local NUM_REPORTS=$(find "${OUTPUT_DIR}/${TARGET_DIR}" -type f -name '*.json' | wc -l)
  echo -e "\e[32m[+]\e[0m ${NUM_REPORTS} complexity reports generated"
}
