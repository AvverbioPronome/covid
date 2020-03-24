git pull --recurse-submodules
git submodule init && git submodule update --remote && git add data && git commit -m "$(date +%F)"
