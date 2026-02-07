FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive


RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    bash fluxbox novnc x11vnc xvfb wget python3 \
    libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 \
    libxtst6:i386 libxrandr2:i386 libglib2.0-0:i386 \
    libgtk2.0-0:i386 libpulse0:i386 libnss3:i386 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


RUN wget https://repo.steampowered.com/steam/archive/precise/steam_latest.deb && \
    apt-get update && \
    apt-get install -y ./steam_latest.deb || apt-get install -fy && \
    rm steam_latest.deb


ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720


RUN echo "#!/bin/bash\n\
Xvfb :1 -screen 0 \${SCREEN_WIDTH}x\${SCREEN_HEIGHT}x24 &\n\
sleep 2\n\
fluxbox &\n\
x11vnc -display :1 -nopw -forever -shared &\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 8080 &\n\
steam" > /start.sh && chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
