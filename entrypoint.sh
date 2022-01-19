#!/usr/bin/env bash

LOTUS_CONFIG=/root/.lotus/config.toml
SERVICE_CONFIG=/opt/filecoin-service.toml

LOTUS_ADDR=${LOTUS_ADDR:-127.0.0.1:1234}

if grep 'model name' /proc/cpuinfo | grep -qi intel; then
  ln -s /opt/coin/lotus-intel /opt/coin/lotus
else
  ln -s /opt/coin/lotus-amd /opt/coin/lotus
fi

mkdir -p /root/.lotus

generate_service_config () {
  JWT=`cat /root/.lotus/token`
  LOTUS_TOKEN=${LOTUS_TOKEN:-$JWT}
  echo -e "[service]\naddress=\"0.0.0.0:3030\"" > $SERVICE_CONFIG
  echo -e "\n[remote_node]\nurl=\"http://${LOTUS_ADDR}/rpc/v0\"\njwt=\"${LOTUS_TOKEN}\"" >> $SERVICE_CONFIG
}

if test $# -eq 0; then
  if [[ -z ${WITHOUT_NODE} ]]; then
    # filecoin-service
    {
      echo 'Waiting for lotus JSON RPC...'
      while ! nc -z -w 1 127.0.0.1 1234; do
        sleep 1
      done
      generate_service_config
      /opt/coin/filecoin-service --config $SERVICE_CONFIG start
    } &
    # lotus
    if [ ! -f $LOTUS_CONFIG ]; then
      echo -e "[API]\nListenAddress=\"/ip4/0.0.0.0/tcp/1234/http\"" > $LOTUS_CONFIG
      echo -e "[Libp2p]\n[Pubsub]\n[Client]\n[Metrics]" >> $LOTUS_CONFIG
    fi
    [ -f $LOTUS_CONFIG ] && sed -i 's^#\s*ListenAddress\s*=\s*"/ip4/127.0.0.1/tcp/1234/http"^ListenAddress="/ip4/0.0.0.0/tcp/1234/http"^g' $LOTUS_CONFIG
    exec /opt/coin/lotus daemon
  else
    generate_service_config
    exec /opt/coin/filecoin-service --config $SERVICE_CONFIG start
  fi
else
  exec $@
fi
