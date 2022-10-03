# get image id
docker images
docker run -it --entrypoint bash 487a0d01f6c1 

# Also, disable buildkit while building to see ids
DOCKER_BUILDKIT=0 docker build --pull --rm -t myproject:latest .
# observe the log, and pick an id.
docker run -ti --rm 487a0d01f6c1
or 
docker run -ti --rm --entrypoint=/bin/sh 487a0d01f6c1


# remove all docker stuf
docker system prune -a --volumes
