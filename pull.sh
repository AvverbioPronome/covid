#!/bin/sh

cd "$(dirname $0)"

if [ ! -z "$(git status --porcelain)" ]; then
    git stash push
    STASHED="true"
fi

git pull
git submodule update --init --remote

if [ ! -z "$(git status --porcelain)" ] || [ "$1" = "--force" ]; then
    git add data && git commit -m "$(date +%F): pull pcm-dpc/COVID-19"

    docker run -v "$(pwd):/home/jovyan/covid" jupyter/scipy-notebook \
           jupyter nbconvert --inplace --execute '/home/jovyan/covid/*.ipynb'

    git add '*.ipynb' && git commit -m "re-run with $(stat -c %y data/dati-json/ | cut -f1 -d' ') data."
fi

if [ ! -z "$STASHED" ]; then
    git stash pop --quiet
    STASHED=""
fi

