#!/bin/sh

_lastmod(){
    date -u +"%F|%R|%Z" -r "$1"
}

# make sure relative paths work:
cd "$(dirname "$0")" || exit 1


if [ -n "$(git status --porcelain)" ]; then
    git stash push --quiet
    STASHED="true"
fi

./download.sh

if [ -n "$(git status --porcelain)" ] || [ "$1" = "--force" ]; then
    git add data/* \
        && git commit -m "$(_lastmod ./data/dati-json/dpc-covid19-ita-regioni.json): new data from pcm-dpc/COVID-19"
    
    docker-compose run jupyter \
                   jupyter nbconvert --to notebook --inplace --execute './covid/*.ipynb'

    git add '*.ipynb' \
        && git commit -m "re-run with $(_lastmod ./data/dati-json/dpc-covid19-ita-regioni.json) data."
fi

if [ ! -d "docs" ] || [ -z "$(ls -A docs)" ] || \
       [ "$(git log -1 --format=%at)" -gt "$(date +%s --utc -r ./docs)" ];
   # don't use _lastmod here, it's an integer comparison
then
    [ -d "docs" ] || mkdir docs
    
    # for github pages
    docker-compose run jupyter \
                   jupyter nbconvert --to html './covid/*.ipynb' --template basic \
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
docker-compose run jupyter jupyter nbconvert --to html './covid/*.ipynb'
