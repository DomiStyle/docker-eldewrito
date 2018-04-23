# Pull ubuntu image
FROM ubuntu:16.04

# Install temporary packages
RUN apt-get update && \
    apt-get install -y wget software-properties-common apt-transport-https cabextract

# Install Wine stable
RUN dpkg --add-architecture i386 && \
    wget https://dl.winehq.org/wine-builds/Release.key && \
    apt-key add Release.key && \
    rm Release.key && \
    apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
    apt-get update && \
    apt-get install -y winehq-stable

# Download winetricks from source
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x ./winetricks

# Install X virtual frame buffer
RUN apt-get install -y xvfb

# Set wine parameters
ENV WINEPREFIX="/wine"
ENV DISPLAY=:1

# Configure wine prefix
RUN WINEDLLOVERRIDES="mscoree,mshtml=" xvfb-run wineboot -u && \
    xvfb-run wineserver -w

# Install VC 2010, VC 2012, fonts and .NET 4.0
RUN xvfb-run ./winetricks -q vcrun2010 vcrun2012 corefonts winhttp dotnet40

# Cleanup
RUN apt-get remove -y wget software-properties-common apt-transport-https cabextract && \
    rm -rf /var/lib/apt/lists/* && \
    rm winetricks

# Add the start script
ADD start.sh .

# Add the default configuration files
ADD defaults defaults

# Make start script executable and create necessary directories
RUN chmod +x start.sh && \
    mkdir config logs

# Set start command to execute the start script
CMD /start.sh

# Set working directory into the game directory
WORKDIR /game

# Expose necessary ports
EXPOSE 11774/udp 11775/tcp 11776/tcp 11777/tcp

# Set volumes
VOLUME /game /config /logs
