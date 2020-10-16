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


# Using pre-built docker image

Using automated build image from <https://hub.docker.com/r/mixhq/filecash/>:

```bash
docker run --rm -itd --name fic -p 1234:1234 -p 3030:3030 -v `pwd`/data:/root/.lotus mixhq/filecash
```
