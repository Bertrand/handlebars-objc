#!/bin/sh

SCRIPT_DIR=`dirname $0`
ROOT_DIR="$SCRIPT_DIR/../.."

git diff --quiet --exit-code
if [ $? -ne 0 ]; then 
    echo "Cannot generate static github pages if you have uncommited changes" 
    exit -1;
fi

GIT_STATUS=`git status -s | grep -e "^\?\?"`
if [ "$GIT_STATUS" != "" ]; then
    echo "cannot swith to gh-pages branch if you have untracked files in your current branch."
    exit -1
fi

current_branch=`git rev-parse --abbrev-ref HEAD`
if [ "$current_branch" == "HEAD" ]; then
    echo "Cannot generate static github pages if you're not on a branch"
    exit -1;
fi 

TMP_FOLDER="/tmp/gh_page_generation"
rm -rf "$TMP_FOLDER"
mkdir -p "$TMP_FOLDER"

cp -RPf "$ROOT_DIR/api_doc/html" "$TMP_FOLDER/api_doc"

pushd . 
cd "$ROOT_DIR"

git checkout gh-pages || { echo "error while checkouting gh-pages branch"; exit -1; }
git clean -df

cp -RPf "$TMP_FOLDER/"* .

GIT_STATUS=`git status -s | grep -e "^\?\?"`
if [ "$GIT_STATUS" != "" ]; then
    echo "Cannot commit gh-pages branch if it contains untracked files. Add the new files if needed and commit your changes."
    echo "You are now on gh-pages branch."
    exit -1
fi

git commit -a -m "update github pages"
git push 

git checkout "$current_branch"
popd