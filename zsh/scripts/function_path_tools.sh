inject_path () {
  # Check to see if it exists and is already in the PATH before unnecessarily concatenating
  if [ -d "$1" ]; then
    if [[ -z "$(echo $PATH | grep "$1")" ]]; then 
      export PATH=$PATH:$1
    fi
  fi
}

prepend_path () {
  # Check to see if it exists and already in the PATH before unnecessarily concatenating
  if [ -d "$1" ]; then
    if [[ -z "$(echo $PATH | grep "$1")" ]]; then 
      export PATH=$1:$PATH
    fi
  fi
}

