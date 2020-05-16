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

RUN ln -s /opt/steam/linux32 ~/.steam/sdk32

ADD maps/* /opt/hlds/cstrike/maps/

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

