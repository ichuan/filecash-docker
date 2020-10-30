FROM rust:latest AS builder
WORKDIR /opt
# build filecoin-service
RUN git clone https://github.com/Zondax/filecoin-signing-tools
RUN cd filecoin-signing-tools && cargo build --release --manifest-path service/Cargo.toml
# build lotus
RUN apt update && apt install -y jq ocl-icd-opencl-dev
RUN wget -c https://dl.google.com/go/go1.14.7.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
RUN git clone https://github.com/filecash/lotus_builder
WORKDIR /opt/lotus_builder
RUN PATH="$PATH:/usr/local/go/bin" bash build.sh -a

FROM ubuntu:18.04
WORKDIR /opt/coin
RUN apt update && apt install -y wget ocl-icd-opencl-dev libssl-dev netcat
COPY --from=builder /opt/filecoin-signing-tools/target/release/filecoin-service /opt/coin/
COPY --from=builder /opt/lotus_builder/lotus/lotus /opt/coin/
COPY ./entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh
# cleanup
RUN apt autoremove -y && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/opt/entrypoint.sh"]
