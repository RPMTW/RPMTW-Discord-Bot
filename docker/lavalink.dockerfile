FROM fredboat/lavalink:master

COPY docker/lavalink_config.yml /opt/Lavalink/application.yml

EXPOSE 2333