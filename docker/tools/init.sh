#!/usr/bin/env sh

if [ -z $1 ]; then
    echo "Please specify a project name";
    exit 1;
fi

name=$1
flags=""
while [ ! -z $2 ]; do
    if [ $2 != "--rm" ]; then
        flags="$flags $2";
    fi
    shift;
done

if [ ! -f /.dockerenv ]; then
    docker compose build;
    docker compose run app init.sh $name "${flags}" --rm ;
    exit;
fi

# inside docker where in <root>:/app
if [ ! -d src ] && [ -z DEBUG ]; then
    buffalo new $1 --vcs none --skip-docker "${flags}";
    mv $1 src;
    rm -rf .git;
    git init;
fi