FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive


RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    bash fluxbox novnc x11vnc xvfb wget python3 sudo \
    libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 \
    libxtst6:i386 libxrandr2:i386 libglib2.0-0:i386 \
    libgtk2.0-0:i386 libpulse0:i386 libnss3:i386 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


RUN wget https://repo.steampowered.com/steam/archive/precise/steam_latest.deb && \
    apt-get update && \
    apt-get install -y ./steam_latest.deb || apt-get install -fy && \
    rm steam_latest.deb


RUN useradd -m render && \
    echo "render ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER render
WORKDIR /home/render

ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720

RUN echo '#!/bin/bash' > /home/render/start.sh && \
    echo 'Xvfb :1 -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x24 &' >> /home/render/start.sh && \
    echo 'sleep 2' >> /home/render/start.sh && \
    echo 'fluxbox &' >> /home/render/start.sh && \
    echo 'x11vnc -display :1 -nopw -forever -shared &' >> /home/render/start.sh && \
    echo '/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 8080 &' >> /home/render/start.sh && \
    echo 'steam -no-browser +open steam://open/minigameslist' >> /home/render/start.sh && \
    chmod +x /home/render/start.sh

EXPOSE 8080

CMD ["/home/render/start.sh"]
