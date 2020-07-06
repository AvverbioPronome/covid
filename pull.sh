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

    git add '*.ipynb' && git commit -m "re-run with $(date --rfc-3339=s --utc -r ./data/dati-json/) data."
fi

if [ -n "$STASHED" ]; then
    git stash pop --quiet
    STASHED=""
fi

