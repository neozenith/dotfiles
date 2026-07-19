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

current_hostname () {
  # Short hostname to tell machines apart at a glance (e.g. mac vs rpi4 over ssh).
  # Prefer `hostname -s`; fall back to `uname -n` where the hostname CLI is absent.
  if command -v hostname >/dev/null 2>&1; then
    hostname -s
  else
    uname -n
  fi
}

