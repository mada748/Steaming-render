FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xvfb \
    x11vnc \
    python3 \
    python3-pip \
    git \
    wget \
    firefox \
    net-tools \
    && apt-get clean

RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html

RUN echo '#!/bin/bash\n\
rm -f /tmp/.X1-lock\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
sleep 3\n\
export DISPLAY=:1\n\
dbus-launch startxfce4 &\n\
x11vnc -display :1 -nopw -forever -shared -rfbport 5900 -localhost &\n\
while ! nc -z localhost 5900; do\n\
  sleep 1\n\
done\n\
/opt/noVNC/utils/websockify/run --web /opt/noVNC $PORT localhost:5900' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
