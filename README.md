# Dockerfiles
### Building docker images

cd to Dockerfile you wish to build
docker build -t induxx/<php:alpine-php-7.3> .

### Pushing docker images

docker login
docker push induxx/<php:alpine-php-7.3>