#!/bin/bash

usage() {
    echo "Usage: ppdb.sh [g|p]
       g - open gameData database
       p - open playerData database"
}

if [ "$1" == "" ]; then
    usage
    exit 1
else
    ppdir=$(findapp2 Pocket Planes)
    cd "$ppdir"
    cd ../Documents

    case $1 in
        'g')
            sqlite3 gameData/user-gameData.db
            exit 0
            shift; shift;;
        'p')
            sqlite3 playerData/user-playerData.db
            exit 0
            shift; shift;;
        *)
            usage
            exit 1
            shift; shift;;
    esac
fi
