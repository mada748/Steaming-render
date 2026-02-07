FROM ubuntu:22.04


ENV DEBIAN_FRONTEND=noninteractive


RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    bash \
    fluxbox \
    novnc \
    x11vnc \
    xvfb \
    wget \
    libgl1-mesa-dri:i386 \
    libgl1-mesa-glx:i386 \
    libsteam-runtime-launcher-service-host-bin:i386 \
    steam:i386 \
    python3 \
    && rm -rf /var/lib/apt/lists/*


ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720


RUN echo "#!/bin/bash\n\
Xvfb :1 -screen 0 \${SCREEN_WIDTH}x\${SCREEN_HEIGHT}x24 &\n\
fluxbox &\n\
x11vnc -display :1 -nopw -forever -shared &\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 8080 &\n\
steam" > /start.sh && chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
