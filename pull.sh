#!/bin/sh

cd "$(dirname "$0")" || exit 1

if [ -n "$(git status --porcelain)" ]; then
    git stash push --quiet
    STASHED="true"
fi

git pull --quiet
git submodule update --init --remote

if [ -n "$(git status --porcelain)" ] || [ "$1" = "--force" ]; then
    git add data && git commit -m "$(date +%s): new commits from pcm-dpc/COVID-19"
    
    docker-compose run jupyter \
                   jupyter nbconvert --inplace --execute './covid/*.ipynb'

    git add '*.ipynb' \
        && git commit -m "re-run with $(date --rfc-3339=s --utc -r ./data/dati-json/) data."
fi

if [ ! -d "docs" ] || [ -z "$(ls -A docs)" ] || \
       [ "$(git log -1 --format=%at)" -gt "$(date +%s --utc -r ./docs)" ];
then
    [ -d "docs" ] || mkdir docs
    
    # for github pages
    docker-compose run jupyter \
                   jupyter nbconvert './covid/*.ipynb' --template basic \
        && mv *.html docs/ \
        && sed -i'' -e '1i ---\n---\n' docs/*.html \
        && git add -f docs/*.html \
        && git commit -m "sync html to commit $(git log -1 --format=%h)"
fi

if [ -n "$STASHED" ]; then
    git stash pop --quiet
    STASHED=""
fi


# for local viewing
# this runs anyway.
docker-compose run jupyter jupyter nbconvert './covid/*.ipynb'
