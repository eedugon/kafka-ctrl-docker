# kafka-ctrl-docker #

Docker image with light kafka control-helper script

# Using with docker-compose #

There is an docker-compose example on `docker-compose/` path.

Example of use:

```command
cd docker-compose
docker-compose run --rm kafka-ctl
```

## Consume and produce example ##

Run this in one terminal in order to create a topic

```command
cd docker-compose
docker-compose run --rm kafka-ctl create-topic testtopic
```

Then starts the consumer

```
docker-compose run --rm kafka-ctl consume testtopic
```

Content of topic will be showed in `stdout`

In other terminal launch the consumer

```
cd docker-compose
docker-compose run --rm kafka-ctl produce testtopic
```

Data to push in topic is reading from `stdin`

## Cleaning procedure ##

**TODO**
