#!/usr/bin/env sh

if [ -z $1 ]; then
    echo "Please specify a project name";
    exit 1;
fi

if [ ! -f /.dockerenv ]; then
    docker compose run app init.sh $1 --rm;
else
    echo "Please run this script outside of docker";
    exit 2;
fi

# inside docker where in <root>:/app
if [ ! -d src ]; then
    buffalo new $1 --vcs none --skip-docker;
    mv $1 src;
    rm -rf .git;
    git init;
fi