# Execute a command and if it fails, return its output and exit
function execHandle {
  TITLE=$1
  shift
  if ! OUTPUT=$("$@")
  then
    echo "Error ${TITLE}: $OUTPUT"
    exit 1
  fi
}
