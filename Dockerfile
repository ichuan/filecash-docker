FROM mixhq/filecoin-signing-tools AS builder
FROM ubuntu:18.04
WORKDIR /opt/coin
RUN apt update && apt install -y wget ocl-icd-opencl-dev libssl-dev netcat
RUN wget https://github.com/filecash/lotus/releases/download/filecash-v0.9.0-fix1/intel-filecash-0.9.0-fix1.tar.gz -O - | tar -C /tmp -xzf -
RUN mv /tmp/lotus /opt/coin/lotus-intel
RUN wget https://github.com/filecash/lotus/releases/download/filecash-v0.9.0-fix1/amd-filecash-0.9.0-fix1.tar.gz -O - | tar -C /tmp -xzf -
RUN mv /tmp/lotus /opt/coin/lotus-amd
COPY --from=builder /opt/filecoin-signing-tools/target/release/filecoin-service /opt/coin/
COPY ./entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh
# cleanup
RUN apt autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/lotus*

ENTRYPOINT ["/opt/entrypoint.sh"]
