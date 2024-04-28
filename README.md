# safehouse-db-schema
safehouse DB

# Docker

## start container with volume and variables

# using command line

docker build -t safehouse-db .

docker run -d \
  --name safehouse-db-container \
  -e POSTGRES_DB=mydatabase \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -p 5432:5432 \
  -v my_postgres_volume:/var/lib/postgresql/data \
  safehouse-db


## start container using dockerfile for variables (alternative - uncomment variables)

docker build -t safehouse-db .

docker run --name safehouse-db-container -p 5432:5432 -d safehouse-db


## stop container

docker stop safehouse-db-container

docker rm safehouse-db-container


## see logs

docker logs safehouse-db-container -f

## shell the container

docker exec -it safehouse-db-container /bin/bash


