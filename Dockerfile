FROM rust:latest AS builder
WORKDIR /opt
RUN git clone https://github.com/Zondax/filecoin-signing-tools
RUN cd filecoin-signing-tools && cargo build --release --manifest-path service/Cargo.toml

FROM ubuntu:18.04
WORKDIR /opt/coin
RUN apt update && apt install -y wget mesa-opencl-icd libssl-dev netcat
RUN wget https://github.com/filecash/lotus/releases/download/filecash-v0.7.0/intel-filecash-0.7.0-fix.tar.gz -O - | tar -C /opt/coin --strip-components 1 -xf -
COPY --from=builder /opt/filecoin-signing-tools/target/release/filecoin-service /opt/coin/
COPY ./entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh
# cleanup
RUN apt autoremove -y && rm -rf /var/lib/apt/lists/*
RUN rm -f /opt/coin/lotus-miner /opt/coin/lotus-worker

ENTRYPOINT ["/opt/entrypoint.sh"]
