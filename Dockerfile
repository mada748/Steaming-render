FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive


RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    bash fluxbox novnc x11vnc xvfb wget python3 sudo xterm wmctrl \
    libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 \
    libxtst6:i386 libxrandr2:i386 libglib2.0-0:i386 \
    libgtk2.0-0:i386 libpulse0:i386 libnss3:i386 \
    ca-certificates && \
    wget https://repo.steampowered.com/steam/archive/precise/steam_latest.deb && \
    apt-get install -y ./steam_latest.deb || apt-get install -fy && \
    rm steam_latest.deb && \
    rm -rf /var/lib/apt/lists/*


RUN useradd -m render && \
    echo "render ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV QT_X11_NO_MITSHM=1
ENV _X11_NO_MITSHM=1

RUN echo '#!/bin/bash\n\
rm -f /tmp/.X1-lock\n\
Xvfb :1 -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x24 &\n\
sleep 3\n\
fluxbox &\n\
sleep 2\n\
x11vnc -display :1 -nopw -forever -shared -bg -rfbport 5900\n\
sleep 2\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 8080 &\n\
sleep 2\n\
xterm -geometry 80x24+10+10 -e "echo Wait for Steam to load...; sleep 5" &\n\
# Launch Steam with sandbox disabled and small mode\n\
steam -no-browser -no-sandbox +open steam://open/minigameslist &\n\
# LOOP TO FORCE FOCUS: Every 5 seconds for 1 minute, try to pull Steam to front\n\
(for i in {1..12}; do sleep 5; wmctrl -a "Steam" || wmctrl -r "Steam" -b add,above; done) &\n\
wait' > /home/render/start.sh && \
    chmod +x /home/render/start.sh && \
    chown render:render /home/render/start.sh

USER render
WORKDIR /home/render
EXPOSE 8080

CMD ["/home/render/start.sh"]
