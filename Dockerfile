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
    git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

RUN cp /opt/noVNC/vnc.html /opt/noVNC/index.html


RUN echo '#!/bin/bash\n\
# Set resolution and start virtual display\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
export DISPLAY=:1\n\
\n\
# Start XFCE\n\
startxfce4 &\n\
\n\
# Start VNC server (listening on 5900)\n\
x11vnc -display :1 -nopw -forever -shared -rfbport 5900 &\n\
\n\
# Start noVNC on the Render-provided $PORT\n\
# The --web flag tells websockify where the HTML/JS files are\n\
/opt/noVNC/utils/websockify --web /opt/noVNC $PORT localhost:5900' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
