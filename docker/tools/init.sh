#!/usr/bin/env sh

if [ -z $1 ]; then
    echo "Please specify a project name";
    exit 1;
fi

if [ ! -f /.dockerenv ]; then
    docker compose build;
    docker compose run app init.sh $1 --rm ;
    exit;
fi

# inside docker where in <root>:/app
if [ ! -d src ] && [ -z DEBUG ]; then
    buffalo new $1 --vcs none --skip-docker;
    mv $1 src;
    rm -rf .git;
    git init;
fi