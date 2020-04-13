#!/bin/sh

if [ ! -z "$(git status --porcelain)" ]; then
    git stash push
    STASHED="true"
fi

git pull
git submodule update --init --remote

if [ ! -z "$(git status --porcelain)" ]; then
    git add data && git commit -m "$(date +%F): pull pcm-dpc data"

    docker run -v "$(pwd):/home/jovyan/covid" jupyter/scipy-notebook \
           jupyter nbconvert --inplace --execute '/home/jovyan/covid/*.ipynb'

    git add '*.ipynb' && git commit -m "re-run with $(git log -1 --format=%s data|cut -d':' -f 1) data."
fi

if [ ! -z "$STASHED" ]; then
    git stash pop --quiet
    STASHED=""
fi

