#!/usr/bin/env bash

LOTUS_CONFIG=/opt/lotus.toml
SERVICE_CONFIG=/opt/filecoin-service.toml

if test $# -eq 0; then
  # generate lotus config.toml
  echo -e "[API]\nListenAddress=\"/ip4/0.0.0.0/tcp/1234/http\"" > $LOTUS_CONFIG
  echo -e "[Libp2p]\n[Pubsub]\n[Client]\n[Metrics]" >> $LOTUS_CONFIG
  /opt/coin/lotus daemon --config $LOTUS_CONFIG &
  # /opt/coin/lotus wait-api
  echo 'Waiting for lotus JSON RPC...'
  while ! nc -z -w 1 127.0.0.1 1234; do
    sleep 1
  done
  # generate filecoin-service.toml
  JWT=`cat /root/.lotus/token`
  echo -e "[service]\naddress=\"0.0.0.0:3030\"" > $SERVICE_CONFIG
  echo -e "\n[remote_node]\nurl=\"http://127.0.0.1:1234/rpc/v0\"\njwt=\"$JWT\"" >> $SERVICE_CONFIG
  exec /opt/coin/filecoin-service --config $SERVICE_CONFIG start
else
  exec $@
fi
