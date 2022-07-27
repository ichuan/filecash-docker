+FROM ghcr.io/ichuan/filecoin-signing-tools AS builder
FROM ubuntu:18.04
WORKDIR /opt/coin
RUN apt update && apt install -y wget ocl-icd-opencl-dev libssl-dev netcat hwloc libhwloc-dev
RUN wget https://github.com/filecash/lotus/releases/download/filecash-v1.5.0/filecash-v1.5.0-intel-18.04.tar.gz -O - | tar -C /tmp -xzf -
RUN mv /tmp/lotus /opt/coin/lotus-intel
RUN wget https://github.com/filecash/lotus/releases/download/filecash-v1.5.0/filecash-v1.5.0-amd-18.04.tar.gz -O - | tar -C /tmp -xzf -
RUN mv /tmp/lotus /opt/coin/lotus-amd
COPY --from=builder /opt/filecoin-service/target/release/filecoin-service /opt/coin/
COPY ./entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh
# cleanup
RUN apt autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/lotus*

ENTRYPOINT ["/opt/entrypoint.sh"]
