#!/bin/sh

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

# Function to create default configuration depending on path
create_default_config()
{
    echo "${YELLOW}Could not find an existing dewrito_prefs.cfg. Using default.${NC}"
    echo "${YELLOW}Make sure to adjust important settings like your RCon password!${NC}"

    sleep 5

    echo "Copying default dewrito_prefs.cfg."
    cp /defaults/dewrito_prefs.cfg $1

    echo "Copying default veto/voting json."

    cp /defaults/veto.json /config
    cp /defaults/voting.json /config
}

echo "Initializing v${CONTAINER_VERSION} for ElDewrito ${ELDEWRITO_VERSION}"

if [ ! -f "eldorado.exe" ]; then
    echo "${RED}Could not find eldorado.exe. Did you mount the game directory to /game?${NC}"

    sleep 2
    exit 1
fi

if [ -z "${SKIP_CHECKSUM_CHECK}" ]; then
    checksum=$(md5sum mtndew.dll | awk '{ print $1 }')

    if [ "$checksum" != "${MTNDEW_CHECKSUM}" ]; then
        echo "${RED}Checksum mismatch! Make sure you are using a valid copy of the game.${NC}"
        echo "${RED}This container only supports ElDewrito ${ELDEWRITO_VERSION}.${NC}";

        echo "Expected ${checksum}"
        echo "Got ${MTNDEW_CHECKSUM}"

        sleep 2
        exit 10
    fi
else
    echo "Skipping checksum check."
fi

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

if [ -z "${INSTANCE_ID}" ]; then
    echo "${YELLOW}Running in single instance mode.${NC}"

    if [ ! -f "dewrito_prefs.cfg" ]; then
        create_default_config "."
    fi
else
    echo "Running in multi instance mode"

    if [ ! -f "/config/dewrito_prefs.cfg" ]; then
        create_default_config "/config"
    fi

    echo "Copying instance configuration"
    cp /config/dewrito_prefs.cfg dewrito_prefs_${INSTANCE_ID}.cfg
fi

echo "Taking ownership of folders"
chown -R $PUID:$PGID /game /config /logs /wine

echo "Changing folder permissions"
find /game /config /logs -type d -exec chmod 775 {} \;

echo "Changing file permissions"
find /game /config /logs -type f -exec chmod 664 {} \;

echo "Cleaning up"
rm /tmp/.X1-lock

echo "Starting virtual frame buffer"
Xvfb :1 -screen 0 320x240x24 &

echo "${GREEN}Starting dedicated server${NC}"
export WINEDLLOVERRIDES="winhttp,rasapi32=n"

if [ -z "${INSTANCE_ID}" ]; then
    su -c "wine eldorado.exe -launcher -dedicated -window -height 200 -width 200 -minimized" eldewrito
else
    echo "Starting instance ${INSTANCE_ID}"
    su -c "wine eldorado.exe -launcher -dedicated -window -height 200 -width 200 -minimized -instance ${INSTANCE_ID}" eldewrito
fi
