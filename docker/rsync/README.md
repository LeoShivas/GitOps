# Build
```bash
DOCKER_BUILDKIT=1 docker build -t mydockerhubuser/rsync .
```

NB : `DOCKER_BUILDKIT=1` [is not required when used with buildx GitHub action](https://github.com/docker/buildx?tab=readme-ov-file#building-with-buildx).

# Push
```bash
docker push mydockerhubuser/rsync
```

