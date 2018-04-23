#!/bin/sh

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

echo "Initializing"

if [ ! -f "eldorado.exe" ]; then
    echo "${RED}Could not find eldorado.exe. Did you mount the game directory to /game?${NC}"
    sleep 2
    exit 1
fi

if [ ! -f "dewrito_prefs.cfg" ]; then
    echo "${YELLOW}Could not find an existing dewrito_prefs.cfg. Using default.${NC}"
    echo "${YELLOW}Make sure to adjust important settings like your RCon password!${NC}"
    sleep 5

    cp /defaults/dewrito_prefs.cfg .

    echo "Copying default veto/voting json."

    cp /defaults/veto.json /config
    cp /defaults/voting.json /config
fi

echo "Starting virtual frame buffer"
Xvfb :1 -screen 0 640x480x24 &

echo "${GREEN}Starting dedicated server${NC}"
wine eldorado.exe -launcher -dedicated -window -height 200 -width 200 -minimized
