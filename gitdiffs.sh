#!/bin/bash

TW_REPOS_HOME=~/triplewhale
FOLLOWING=( \
  backend/services/charif \
  backend/services/google-sheets \
  devops/pulumi/ai-infra \
  backend/packages/test-utils \
  backend/packages/saber \
  )
HELPTEXT="\n
Git diff checker can check for commits in your repos since a date\n\n
USAGE:\n\n
\tgitdiffs\t\tFor each repo in the \$FOLLOWING array, list all commits since yesterday\n\n
\t\t\t\twith full diff info for each commit\n\n
OPTIONS: (only first one is used)\n\n
\t-r <number>\tFor the repo with index <number>, list all commits since yesterday\n
\t-d <date>\tList all commits since <date> (e.g. '2021-01-01', '3 days ago')\n
\t-n\t\tList the last N commits, regardless of date\n
"
SINCE="yesterday"
N_COMMITS=""
FULL_DIFF=0
while getopts "d:n:" opt; do
  case $opt in
    d)
      SINCE=$OPTARG
      ;;
    n)
      N_COMMITS=$OPTARG
      ;;
    \?)
      echo -e $HELPTEXT
      exit 1
      ;;
  esac
done
echo "Commits $N_COMMITS"
echo "Since $SINCE"
echo "Full diff $FULL_DIFF"
if [ -z $1 ]; then
  for i in ${!FOLLOWING[@]}; do
    REPO=${FOLLOWING[$i]}
    echo "[$i] $REPO"
    cd $TW_REPOS_HOME/$REPO
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=local "master@{$SINCE}..master" -- .
    echo ''
  done
elif [[ $1 =~ ^[0-9]+$ ]]; then
  echo "[$1] ${FOLLOWING[$1]}"
  REPO=${FOLLOWING[$1]}
  if [[ -n "$N_COMMITS" ]]; then
    COMMITS="-n $N_COMMITS"
  else
    COMMITS="-p master@{$SINCE}..master"
  fi
  cd $TW_REPOS_HOME/$REPO
    echo "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=local $COMMITS"
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=local $COMMITS
elif [[ -n "$N_COMMITS" ]]; then
  for i in ${!FOLLOWING[@]}; do
    REPO=${FOLLOWING[$i]}
    echo "[$i] $REPO"
    cd $TW_REPOS_HOME/$REPO
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=local -n $N_COMMITS master
    echo ''
  done
else
  for i in ${!FOLLOWING[@]}; do
    REPO=${FOLLOWING[$i]}
    echo "[$i] $REPO"
    cd $TW_REPOS_HOME/$REPO
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=local --since="{$2}" master -- .
    echo ''
  done
fi


