#! /bin/bash

# Author: Josh Peak
# email: neozenith.dev@gmail.com
# date: 2017-07-14
# desc: Helper script to setup your git configuration on various platforms
# For windows use this on Git Bash. OSX and Linux just use Bash.
# USAGE: git-cfg.sh CFG_SCOPE [KEYS_DIR]
#  CFG_SCOPE  - This has values either -l or -g to apply git config to local
#               repository or the global scope git config.
#  KEYS_DIR   - This optional argument takes an absolute directory path to where
#               you keep your certificate and keys. Defaults to $HOME/keys.
#               Alternatively if you are in your keys directory run this script
#               git-cfg.sh -g $(pwd)
#               this will pass the present working directory.


###########################
# Parse Arg 1: Config Scope
###########################

CFG_SCOPE="--local"
if [[ $1 == "-g" ]]; then
  CFG_SCOPE="--global"
elif [[ $1 == "-l" ]]; then
  CFG_SCOPE="--local"
else
  echo " USAGE: git-cfg.sh CFG_SCOPE [KEYS_DIR]"
  echo "  CFG_SCOPE  - This has values either -l or -g to apply git config to local"
  echo "               repository or the global scope git config."
  echo "  KEYS_DIR   - This optional argument takes an absolute directory path to where"
  echo "               you keep your certificate and keys. Defaults to $HOME/keys."
  echo "               Alternatively if you are in your keys directory run this script"
  echo "               git-cfg.sh -g $(pwd)"
  echo "               this will pass the present working directory."
fi
echo "$CFG_SCOPE"

##########################################################
# Parse Arg 2: [Optional] Directory storing keys and certs
##########################################################
KEYS_DIR="$HOME/keys"
if [[ $2 != "" ]]; then
  KEYS_DIR=$2
fi
echo "$KEYS_DIR"

#######################################
# Defaults and Platform specific tweaks
#######################################
PASS_PROTECTED=0
USER=neozenith

echo "Detected $OSTYPE..."
if [[ $OSTYPE == "msys" ]]; then
  echo "Git Bash on Windows"
  PASS_PROTECTED=1
  CREDENTIAL_HELPER="manager"

elif [[ $OSTYPE == "darwin*" ]]; then
  CREDENTIAL_HELPER="osxkeychain"

else
  CREDENTIAL_HELPER="cache"

fi

###################################
# Specific Git Servers to configure
###################################
GITHUB_SERVER="https://github.com"
GITLAB_SERVER="https://gitlab.com"
DEXATA_SERVER="https://entrance.c-esolutions.com.au"
# Array of servers to configure
SERVERS="$GITHUB_SERVER $GITLAB_SERVER $DEXATA_SERVER"

for SERVER in $SERVERS;do

  echo "================================================="
  echo "Configuring: $SERVER"
  echo "================================================="
 
  # Default .gitconfig shouldn't have the helper per configured
  CONFIGURED=$(git config $CFG_SCOPE credential.$SERVER.helper)
  if [[ -n $CONFIGURED ]]; then
    echo "Already configured $SERVER"
    git config $CFG_SCOPE -l | grep $SERVER
  else

    git config $CFG_SCOPE core.askpass ""

    if [[ $SERVER == $DEXATA_SERVER ]]; then
      git config $CFG_SCOPE http.$SERVER.sslVerify 1
      git config $CFG_SCOPE http.$SERVER.sslCAPath $KEYS_DIR
      git config $CFG_SCOPE http.$SERVER.sslCAInfo $KEYS_DIR/isca.crt
      git config $CFG_SCOPE http.$SERVER.sslCert $KEYS_DIR/joshpeakcert.pem
      git config $CFG_SCOPE http.$SERVER.sslCertPasswordProtected $PASS_PROTECTED
    fi

    git config $CFG_SCOPE credential.$SERVER.username $USER
    git config $CFG_SCOPE credential.$SERVER.helper $CREDENTIAL_HELPER
    git config $CFG_SCOPE credential.$SERVER.modalprompt 0
    echo "Successfully Configured"
    git config $CFG_SCOPE -l | grep $SERVER
  fi

done


