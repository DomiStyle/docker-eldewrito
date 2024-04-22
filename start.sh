#!/bin/sh

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

echo "Initializing v${CONTAINER_VERSION} for ElDewrito ${ELDEWRITO_VERSION}"

# Search for eldorado.exe in game directory
if [ ! -f "eldorado.exe" ]; then
    echo "${RED}Could not find eldorado.exe. Did you mount the game directory to /game?${NC}"

    sleep 2
    exit 1
fi

# Checksum the mtndew.dll to confirm we're running the correct version
if [ -z "${SKIP_CHECKSUM_CHECK}" ]; then
    checksum=$(md5sum mtndew.dll | awk '{ print $1 }')

    if [ "$checksum" != "${MTNDEW_CHECKSUM}" ]; then
        echo "${RED}Checksum mismatch! Make sure you are using a valid copy of the game.${NC}"
        echo "${RED}This container only supports ElDewrito ${ELDEWRITO_VERSION}.${NC}"

        echo "Expected ${checksum}"
        echo "Got ${MTNDEW_CHECKSUM}"

        sleep 2
        exit 10
    fi
else
    echo "Skipping checksum check."
fi

# Create user if container should run as user
if [ -z "${RUN_AS_USER}" ]; then
    echo "Running as root"
    user=root

    if [ $PUID -ne 0 ] || [ $PGID -ne 0 ]; then
        echo "${RED}Tried to set PUID OR PGID without setting RUN_AS_USER.${NC}"
        echo "${RED}Please set RUN_AS_USER or remove PUID & PGID from your environment variables.${NC}"

        sleep 2
        exit 40
    fi
else
    echo "Running as eldewrito"
    user=eldewrito

    if [ $PUID -lt 1000 ] || [ $PUID -gt 60000 ]; then
        echo "${RED}PUID is invalid${NC}"

        sleep 2
        exit 20
    fi

    if [ $PGID -lt 1000 ] || [ $PGID -gt 60000 ]; then
        echo "${RED}PGID is invalid${NC}"

        sleep 2
        exit 30
    fi

    if ! id -u eldewrito > /dev/null 2>&1; then
        echo "Creating user"
        useradd -u $PUID -m -d /tmp/home eldewrito
    fi
fi

if [ ! -f "data/dewrito_prefs.cfg" ]; then
    echo "${YELLOW}Could not find an existing dewrito_prefs.cfg. Using default.${NC}"
    echo "${YELLOW}Make sure to adjust important settings like your RCon password!${NC}"

    sleep 5

    echo "Copying default dewrito_prefs.cfg"
    cp /defaults/dewrito_prefs.cfg data/

    if [ ! -d "data/server" ]; then
        mkdir data/server
    fi

    if [ ! -f "data/server/voting.json" ]; then
        echo "Copying default voting.json"
        cp /defaults/voting.json data/server/
    fi
fi

if [ -z "${SKIP_CHOWN}" ]; then
    echo "Taking ownership of folders"
    chown -R $PUID:$PGID /game /wine

    echo "Changing folder permissions"
    find /game -type d -exec chmod 775 {} \;

    echo "Changing file permissions"
    find /game -type f -exec chmod 664 {} \;
fi

# Xvfb needs cleaning because it doesn't exit cleanly
echo "Cleaning up"
rm /tmp/.X1-lock

echo "Starting virtual frame buffer"
Xvfb :1 -screen 0 320x240x24 &

echo "${GREEN}Starting dedicated server${NC}"

# DLL overrides for Wine are required to prevent issues with master server announcement
export WINEDLLOVERRIDES="winhttp,rasapi32=n"

if [ ! -z "${WINE_DEBUG}" ]; then
    echo "Setting wine to verbose output"
    export WINEDEBUG=warn+all
fi

su -c "wine eldorado.exe -launcher -dedicated -window -height 200 -width 200 -minimized" $user

if [ -z "${WAIT_ON_EXIT}" ]; then
    echo "${RED}Server terminated, exiting${NC}"
else
    echo "${RED}Server terminated, waiting${NC}"
    sleep infinity
fi
