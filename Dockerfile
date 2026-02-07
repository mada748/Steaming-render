
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
    && apt-get clean


RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html


RUN echo '#!/bin/bash\n\
# Start a virtual X server in the background\n\
Xvfb :1 -screen 0 1280x800x24 &\n\
export DISPLAY=:1\n\
\n\
# Start the XFCE desktop session\n\
startxfce4 &\n\
\n\
# Start the VNC server (no password for ease of use, listening on 5901)\n\
x11vnc -display :1 -nopw -forever -shared -rfbport 5901 &\n\
\n\
# Start noVNC proxy to bridge VNC to the web port Render provides\n\
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen $PORT' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
