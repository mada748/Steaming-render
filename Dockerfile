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
    git clone https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify
    
RUN echo '#!/bin/bash\n\
# 1. Start virtual display\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
sleep 2\n\
export DISPLAY=:1\n\
\n\
# 2. Start Desktop Environment\n\
startxfce4 &\n\
\n\
# 3. Start VNC Server\n\
x11vnc -display :1 -nopw -forever -shared -rfbport 5900 &\n\
sleep 2\n\
\n\
# 4. Start the Proxy\n\
# Notice we call the python script INSIDE the directory specifically\n\
/opt/noVNC/utils/websockify/run --web /opt/noVNC $PORT localhost:5900' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
