FROM ubuntu:latest

ENV PORT 27015
ENV MAP de_dust2
ENV MAXPLAYERS 16
ENV SV_LAN 1

RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get install wget lib32gcc1 -qq

WORKDIR /steamcmd

RUN wget http://media.steampowered.com/client/steamcmd_linux.tar.gz && \
	tar xfz steamcmd_linux.tar.gz && \
	rm steamcmd_linux.tar.gz

RUN ./steamcmd.sh +login anonymous +force_install_dir /opt/hlds +app_update 90 validate +quit || true
RUN ./steamcmd.sh +login anonymous +app_update 70 +quit || true
RUN ./steamcmd.sh +login anonymous +app_update 10 +quit || true
RUN ./steamcmd.sh +login anonymous +force_install_dir /opt/hlds +app_update 90 validate +quit

RUN ln -s /steamcmd/linux32 ~/.steam/sdk32

WORKDIR /opt/hlds

ADD ./maps ./cstrike/maps

EXPOSE $PORT/udp
EXPOSE $PORT/tcp

CMD ./hlds_run -game cstrike -strictportbind -autoupdate \
	-ip 0.0.0.0 \
	-port $PORT \
	+sv_lan $SV_LAN \
	+map $MAP \
	-maxplayers $MAXPLAYERS
