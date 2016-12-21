#!/bin/bash
# Push Coala fixes back to the repo if on gh-pages branch
# make a branch per fix
FIX_BRANCH=coala-fix-$TRAVIS_BUILD_NUMBER
# only do this on gh-page branch
if [ $TRAVIS_BRANCH = "gh-pages" ]; then
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "coala-autofix-bot"
    git checkout -B $FIX_BRANCH
    git add .
    # check for changes
    git status --porcelain|grep "A"
    # if there are changes
    if [ $? = 0 ]; then
        git commit --message "Coala auto-patch for Travis CI Build:$TRAVIS_BUILD_NUMBER | Generated by Travis CI"
        git remote add origin-pages https://coala-autofix-bot:$COALA_FIXER@github.com/fossasia/gci16.fossasia.org.git
        git push --quiet --set-upstream origin-pages $FIX_BRANCH
        curl -X POST -H "Authorization: token $GITHUB_TOKEN" --data '{"title":"coala-fixes for build '$TRAVIS_BUILD_NUMBER'", "body":"Automated Coala fixes:'$TRAVIS_BUILD_NUMBER'", "head":"'$FIX_BRANCH'", "base":"gh-pages"}' https://api.github.com/repos/fossasia/gci16.fossasia.org/pulls;
    else
        echo "No changes detected. Not creating a patch."
    fi
else
    echo "Not creating a patch since not on gh-pages branch"
fi
