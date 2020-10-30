#!/usr/bin/env bash

LOTUS_CONFIG=/root/.lotus/config.toml
SERVICE_CONFIG=/opt/filecoin-service.toml

LOTUS_ADDR=${LOTUS_ADDR:-127.0.0.1:1234}
LOTUS=/opt/coin/lotus-amd

if grep 'model name' /proc/cpuinfo | grep -qi intel; then
  LOTUS=/opt/coin/lotus-intel
fi

mkdir -p /root/.lotus

if test $# -eq 0; then
  if [[ -z ${WITHOUT_NODE} ]]; then
    # generate lotus config.toml
    if [ ! -f $LOTUS_CONFIG ]; then
      echo -e "[API]\nListenAddress=\"/ip4/0.0.0.0/tcp/1234/http\"" > $LOTUS_CONFIG
      echo -e "[Libp2p]\n[Pubsub]\n[Client]\n[Metrics]" >> $LOTUS_CONFIG
    fi
    $LOTUS daemon &
    # $LOTUS wait-api
    echo 'Waiting for lotus JSON RPC...'
    while ! nc -z -w 1 127.0.0.1 1234; do
      sleep 1
    done
  fi
  # generate filecoin-service.toml
  JWT=`cat /root/.lotus/token`
  LOTUS_TOKEN=${LOTUS_TOKEN:-JWT}
  echo -e "[service]\naddress=\"0.0.0.0:3030\"" > $SERVICE_CONFIG
  echo -e "\n[remote_node]\nurl=\"http://${LOTUS_ADDR}/rpc/v0\"\njwt=\"${LOTUS_TOKEN}\"" >> $SERVICE_CONFIG
  exec /opt/coin/filecoin-service --config $SERVICE_CONFIG start
else
  exec $@
fi
