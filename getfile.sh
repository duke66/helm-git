#!/usr/bin/env sh

set -e 

URI=$@ # eg: gitlab://username:pass@srv/project:master/kubernetes/helm-chart
PROVIDER=$(echo $URI | cut -d: -f1) # eg: gitlab
AUTH=$(echo $URI | cut -d: -f2,3 | sed -e "s/\/\///" | cut -d\@ -f1) # eg: gitlab
SRV=$(echo $URI | cut -d\@ -f2 | cut -d\/ -f1) # eg: gitlab
REPO=$(echo $URI | cut -d\@ -f2 | cut -d\/ -f2,3,4,5 | cut -d: -f1) 
BRANCH=$(echo $URI | cut -d\/ -f5| cut -d: -f2)
FILEPATH=$(echo $URI | cut -d\/ -f6,7,8,9,10,11,12,13 | sed -e "s/$BRANCH\///") # eg: kubernetes/helm-chart

#echo $URI $REPO $BRANCH $FILEPATH 

# make a temporary dir
TMPDIR="$(mktemp -d)"
cd $TMPDIR

git init --quiet
git remote add origin https://$AUTH@$SRV/$REPO.git
git pull --depth=1 --quiet origin $BRANCH

if [ -f $FILEPATH ]; then # if a file named $FILEPATH exists
  cat $FILEPATH | sed 's/__CI_JOB_TOKEN__/'"${CI_JOB_TOKEN}"'/'
else
  echo "Error in plugin 'helm-git': $BRANCH:$FILEPATH does not exists" >&2
  find $TMPDIR
  exit 1
fi

# remove the temporary dir
#rm -rf $TMPDIR
