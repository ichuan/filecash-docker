# filecash-docker
Dockerfile for filecash


# Building

```bash
docker build -t filecash .
```

# Running

```bash
# block dir
mkdir data
docker run --rm -itd --name fic -p 1234:1234 -p 3030:3030 -v `pwd`/data:/root/.lotus filecash

# create readonly token
docker exec -it fic /opt/coin/lotus auth create-token --perm read
```


# Only running filecoin-service

Don't run the lotus node

```bash
docker run -e WITHOUT_NODE=1 -e LOTUS_ADDR=1.1.1.1:1234 -e LOTUS_TOKEN=THE_JWT_TOKEN --rm -itd --name fic -p 1234:1234 -p 3030:3030 -v `pwd`/data:/root/.lotus filecash
```


# Using pre-built docker image

Using automated build image from <https://hub.docker.com/r/wshub/filecash/>:

```bash
docker run --rm -itd --name fic -p 1234:1234 -p 3030:3030 -v `pwd`/data:/root/.lotus wshub/filecash
```
