#! /bin/bash
function inject_path () {
  # Check to see if it exists and is already in the PATH before unnecessarily concatenating
  if [ -d "$1" ]; then
    if [[ -z "$(echo $PATH | grep "$1")" ]]; then 
      export PATH=$PATH:$1
    fi
  fi
}

# Export bash function to work as command line command as well
export -f inject_path 

function prepend_path () {
  # Check to see if it exists and already in the PATH before unnecessarily concatenating
  if [ -d "$1" ]; then
    if [[ -z "$(echo $PATH | grep "$1")" ]]; then 
      export PATH=$1:$PATH
    fi
  fi
}

# Export bash function to work as command line command as well
export -f prepend_path 
