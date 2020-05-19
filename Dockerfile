FROM debian:latest

ENV PORT 27015

RUN apt update && \
	apt install -y lib32gcc1 wget

WORKDIR /opt/steam

RUN wget http://media.steampowered.com/client/steamcmd_linux.tar.gz && \
        tar xfz steamcmd_linux.tar.gz && \
        rm steamcmd_linux.tar.gz

RUN ./steamcmd.sh +login anonymous +force_install_dir /opt/hlds +app_update 90 validate +quit || true
RUN ./steamcmd.sh +login anonymous +force_install_dir /opt/hlds +app_update 70 validate +quit || true
RUN ./steamcmd.sh +login anonymous +force_install_dir /opt/hlds +app_update 10 validate +quit || true
RUN ./steamcmd.sh +login anonymous +force_install_dir /opt/hlds +app_update 90 validate +quit

RUN ln -s /opt/steam/linux32 ~/.steam/sdk32 && \
	sed -e '/hostname/ s/^#*/\/\/ /' -i /opt/hlds/cstrike/server.cfg

ADD maps/* /opt/hlds/cstrike/maps/
COPY files/mapcycle.txt /opt/hlds/cstrike/mapcycle.txt

# Install metamod
WORKDIR /opt/hlds/cstrike/addons/metamod/dlls
RUN wget "http://prdownloads.sourceforge.net/metamod/metamod-1.20-linux.tar.gz" && \
        tar xfz metamod-1.20-linux.tar.gz && \
        rm metamod-1.20-linux.tar.gz
COPY files/liblist.gam /opt/hlds/cstrike/liblist.gam

# Install dproto
COPY files/dproto_i386.so /opt/hlds/cstrike/addons/dproto/dproto_i386.so
COPY files/dproto.cfg /opt/hlds/cstrike/dproto.cfg
RUN echo "linux addons/dproto/dproto_i386.so" >> "/opt/hlds/cstrike/addons/metamod/plugins.ini"

# Install AMX Mod X
WORKDIR /opt/hlds/cstrike
RUN wget "https://www.amxmodx.org/amxxdrop/1.9/amxmodx-1.9.0-git5263-base-linux.tar.gz" && \
        tar xfz amxmodx-1.9.0-git5263-base-linux.tar.gz && \
        rm amxmodx-1.9.0-git5263-base-linux.tar.gz && \
	find maps -name "*.bsp" -exec basename {} .bsp \; >> /opt/hlds/cstrike/addons/amxmodx/configs/maps.ini && \
	echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> "/opt/hlds/cstrike/addons/metamod/plugins.ini"

EXPOSE $PORT/udp
EXPOSE $PORT/tcp

WORKDIR /opt/hlds

CMD ./hlds_run -game cstrike -strictportbind -autoupdate \
        -ip 0.0.0.0 \
        -port $PORT \
        +sv_lan ${SV_LAN:-1} \
        +hostname ${SERVER_NAME:-Counter-Strike 1.6 Server} \
        +map ${MAP:-de_dust2} \
        -maxplayers ${MAXPLAYERS:-32}

