#! /bin/bash
ccurl() {
  ESC_CODE=""
  if [[ $OSTYPE == darwin* ]]; then
    ESC_CODE=`echo -e "\033"`
  else
    ESC_CODE=`echo -e "\e"`
  fi
  RED="$ESC_CODE\[31m"
  GREEN="$ESC_CODE\[32m"
  YELLOW="$ESC_CODE\[33m"
  BLUE="$ESC_CODE\[34m"
  PURPLE="$ESC_CODE\[36m"
  
  LRED="$ESC_CODE\[91m"
  LGREEN="$ESC_CODE\[92m"
  LYELLOW="$ESC_CODE\[93m"
  LBLUE="$ESC_CODE\[94m"
  LPURPLE="$ESC_CODE\[96m"
  NORM="$ESC_CODE\[0m"

  # curl verbose header information is piped to stderr
  # We need to pipe stderr (2>) to stdout (1>) using >&
  # Apply colourising pattern matchers
  curl -sv "$@" 2>&1 | \
    sed -E "s/^(>) (.*): (.*)$/$RED\1 $LBLUE\2: $LRED\3$NORM/g" | \
    sed -E "s/^(<) (.*): (.*)$/$GREEN\1 $LBLUE\2: $LGREEN\3$NORM/g" | \
    sed -E "s/^(\*) (.*)$/$PURPLE\1 $NORM\2$NORM/g" | \
    sed -E "s/^(<) (.*)$/$GREEN\1 $GREEN\2$NORM/g" | \
    sed -E "s/^(>) (.*)$/$RED\1 $RED\2$NORM/g"
}
# Export bash function to work as command line command as well
export -f ccurl

