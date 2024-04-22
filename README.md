<img src="http://i.imgur.com/IkTrjna.png" width="190" height="164" align="right"/>

# ElDewrito dedicated server dockerized

## About

This is a Dockerfile for running the ElDewrito server under Linux. The container uses Wine to run the Windows application and xvfb to create a virtual desktop.

The container is running 100% headless - no GUI is required for installation, execution or configuration.

The game files are required in order to start this container. They are not bundled within the container and you will have to provide them.

## Usage

See the `docker-compose.yml.example` [here](https://github.com/DomiStyle/docker-eldewrito/blob/master/docker-compose.yml.example) (recommended) or manually start the container with the following command:

```
docker run -d -p 11774:11774/udp -p 11775:11775/tcp -p 11776:11776/tcp -p 11777:11777/tcp -v /opt/gamepath:/game --cap-add=SYS_PTRACE domistyle/eldewrito
```

For multiple instances take a look at the `docker-compose.yml.example_multiinstance` file [here](https://github.com/DomiStyle/docker-eldewrito/blob/master/docker-compose.yml.example_multiinstance).

**The capability SYS_PTRACE is required due to how ElDewrito works. The server won't start without it.**

A [default configuration file](https://github.com/DomiStyle/docker-eldewrito/blob/master/defaults/dewrito_prefs.cfg) and voting rules will be created automatically if no configuration exists in the game directory. If you do not want to use this configuration you can override this behavior by creating your own dewrito_prefs.cfg before starting the container.

### Tags

The following tags are available:

| Name       | Description |
|------------|-------------|
| `latest` | Direct build from master branch. Use this one unless you know what you're doing. |
| `X.Y-testZ` | Tagged builds taken from master branch. Used for testing. |
| `X.Y` | Stable tags. Everything was tested and is working. |

## Tutorial (for Ubuntu hosts)

1. Prepare a Ubuntu host
2. Install Docker for Ubuntu by following [this guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
3. Make sure Docker is working by running `docker -v`
4. Grab the latest compose file from the git repository [here](https://raw.githubusercontent.com/DomiStyle/docker-eldewrito/master/docker-compose.yml.example) (or [this one](https://github.com/DomiStyle/docker-eldewrito/blob/master/docker-compose.yml.example_multiinstance) for multiple instances)
5. Put the file in a folder called `eldewrito` and rename it to `docker-compose.yml`
6. Switch into the folder and open the file with `nano docker-compose.yml`
7. Adjust the game path `/opt/eldewrito` if necessary
8. Put your Eldewrito game files into the folder you specified for the volume at /game
9. Run `docker compose up -d`

You're done. Your container will now be running and you can check if it is working by visting http://server_ip:11775 in your browser.

You can use `docker ps` to view running containers.

To update the container either change the image tag inside of your docker-compose.yml and run `docker compose up -d` or use `docker compose pull` followed by `docker compose up -d` if you are using the latest tag.

You can use `docker compose logs` to view the logs inside of the container.

## Configuration

### Ports
| Port       | Protocol | Description |
|------------|----------|-------------|
| `11774` | UDP | Used for the game traffic |
| `11775` | TCP | Runs the HTTP server used for communication with clients |
| `11776` | TCP | Used for controlling the server via RCon |
| `11777` | TCP | VoIP |

### Volumes

| Path       | Description | Required |
|------------|-------------|----------|
| `/game` | Has to be mounted with the ElDewrito game files in place. | Yes |
| `/game/data` | Contains the dewrito_prefs.cfg and voting.json, automatically created if left empty on start. | No |
| `/game/logs` | Contains the log files. | No |
| `/game/mods` | Contains the mod files. | No |

### Environment variables

| Variable  | Description | Default  | Required |
|-----------|-------------|----------|----------|
| `PUID` | The user that the game server should be started as. | 1000 | No |
| `PGID` | The group that should own the game files. | 1000 | No |
| `SKIP_CHECKSUM_CHECK` | Set to true or 1 to disable the checksum check performed on container start. (not recommended) | - | No |
| `SKIP_CHOWN` | Skips the chowning on container startup. Speeds up container startup but requires proper directory permissions. | - | No |
| `WAIT_ON_EXIT` | Set to true or 1 to wait before the container exits. | - | No |
| `WINE_DEBUG` | Set to true or 1 to get verbose output from Wine. | - | No |
