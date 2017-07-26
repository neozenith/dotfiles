#! /bin/bash
# Usage: changelog.sh [lasttag|tagref|branch_ref] [JIRA Host]
#
# By default this script will evaluate the git log messages between the current HEAD
# and the develop branch. eg develop..HEAD 
# It will blacklist and whitelist commit messages based upon
# the regular expressions defined below and prefix the output format with markdown
# bullet points.
#
# ```
# # USAGE:
# changelog.sh 
# ```
#
# If you pass in a different refspec as the first argument it will get a 
# changelog between that argument and HEAD
# 
# ```
# git checkout develop
#
# # From a Branch
# # master..HEAD
# changelog.sh master
#
# # From a Tag
# # v3.12.0..HEAD
# changelog.sh v3.12.0
# ```
#
# The above snippet when run from develop relative to the last tagged release or
# more simply the following:
#
# changelog.sh lasttag
#
# JIRA Linking:
# If you want to replace any text in your changelog with markdown links to your
# JIRA Issue tracking system then pass in your host as the second argument
#
# ```
# # Example:
# # develop..HEAD
# changelog.sh develop jira.atlassian.net
# ```


BASE_BRANCH=develop
LAST_TAG=`git describe --abbrev=0 --tags 2> /dev/null | grep -E '^v\d\.\d\.\d'`
BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`

if [[ -n "$1" ]]; then
  BASE_BRANCH=$1
fi

if [[ "$1" == "lasttag" ]]; then
  BASE_BRANCH=$LAST_TAG
fi
# echo $BASE_BRANCH
MERGE_BASE=`git merge-base $BASE_BRANCH $BRANCH`

#####################
# Regular Expressions
#####################
# ADD_WHITE_LIST="(^ - (add(ed)?):)"
ADD_WHITE_LIST="(^ - (add(ed)?):)|(^ - Merge branch '.+' into '$BRANCH')"
CHG_WHITE_LIST="(^ - (chg|upd|update(d)?|change(d)?):)"
FIX_WHITE_LIST="(^ - (fix|bug):)"
MISC_WHITE_LIST="(^ - (sec|dep|rem):)"
BLACK_LIST="(wip|dbg|WIP|DEBUG):"

#######################
# Git Log Configuration
#######################
# ----
# Have to use backticks to execute the echo statement to explicitly allow the
# double dashed arguments to be resolved as a string substitution later.
LOG_ARGS=`echo "--oneline"`
# ----
# https://git-scm.com/docs/git-log#_pretty_formats
# LOG_FORMAT=" - %<(100,trunc)%s [%an](mailto:%ae)"
LOG_FORMAT=" - %s"

####################
# WIP: JIRA Issue Linking 
####################
# ----
# Define Jira host to scrape out of changelogs 
# and replace with valid markdown links
JIRA_HOST=$2

JIRA_SED_EXP=""  
if [[ -n $JIRA_HOST ]]; then
  JIRA_URL="https://$JIRA_HOST/browse/"
  JIRA_URL="$(echo $JIRA_URL | sed -e 's/\//\\\//g')"
  JIRA_SED_EXP="s/\([A-Z][A-Z]*-[0-9][0-9]*\)/\[\1\]\($JIRA_URL\1\)/g"
fi
# ----

echo "## Changelog $BASE_BRANCH..$BRANCH ($(date))"
echo ""
echo "#### Added:"
if [[ -n $JIRA_HOST ]]; then
  git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$ADD_WHITE_LIST" | sed -e $JIRA_SED_EXP
else
  git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$ADD_WHITE_LIST"
fi

echo ""
echo "#### Updated:"
if [[ -n $JIRA_HOST ]]; then
  git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$CHG_WHITE_LIST" | sed -e $JIRA_SED_EXP
else
  git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$CHG_WHITE_LIST"
fi

echo ""
echo "#### Fixed:"
if [[ -n $JIRA_HOST ]]; then
  git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$FIX_WHITE_LIST" | sed -e $JIRA_SED_EXP
else
  git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$FIX_WHITE_LIST"
fi

echo ""
echo "#### Other Changes:"
if [[ -n $JIRA_HOST ]]; then
  git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$MISC_WHITE_LIST" | sed -e $JIRA_SED_EXP
else
  git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$MISC_WHITE_LIST" 
fi
