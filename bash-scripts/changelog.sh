#! /bin/bash
# Usage: changelog.sh [lasttag|tagref|branch_ref]
#
# By default this script will evaluate the git log messages between the current HEAD
# and the develop branch. It will blacklist and whitelist commit messages based upon
# the regular expressions defined below and prefix the output format with markdown
# bullet points.
#
# changelog.sh | sort
#
# This will arrange the output into the commit message categories
#
# git checkout develop
# changelog.sh v3.12.0 | sort
# changelog.sh master | sort
#
# The above snippet when run from develop relative to the last tagged release or
# more simply the following:
#
# changelog.sh lasttag

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
# JIRA Issue Linking 
####################
# ----
# Define Jira project code to scrape out of changelogs 
# and replace with valid markdown links
JIRA_PRJ="HOR"
JIRA_HOST="dexata.atlassian.net"
# ----
JIRA_URL="https://$JIRA_HOST/browse/"
JIRA_URL="$(echo $JIRA_URL | sed -e 's/\//\\\//g')"
JIRA_SED_EXP="s/\($JIRA_PRJ-[0-9][0-9]*\)/\[\1\]\($JIRA_URL\1\)/g"

echo "## Changelog $BASE_BRANCH..$BRANCH ($(date))"
echo ""
echo "#### Added:"
git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$ADD_WHITE_LIST" | sed -e $JIRA_SED_EXP
echo ""
echo "#### Updated:"
git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$CHG_WHITE_LIST" | sed -e $JIRA_SED_EXP
echo ""
echo "#### Fixed:"
git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$FIX_WHITE_LIST" | sed -e $JIRA_SED_EXP
echo ""
echo "#### Other Changes:"
git log $LOG_ARGS --format="$LOG_FORMAT" $MERGE_BASE..$BRANCH | egrep -v "$BLACK_LIST" | egrep "$MISC_WHITE_LIST" | sed -e $JIRA_SED_EXP

