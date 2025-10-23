# Spread Toolkit Docker Usage Guide

This guide explains how to run the **Spread Toolkit** using Docker and Docker Compose. It covers network setup, container IP assignment, configuration, and port mapping.

## 1. Create a Docker Network

Create a dedicated Docker network:

```bash
docker network create \
  --driver bridge \
  --subnet 172.18.0.0/16 \
  spreadnet
```

This will create a bridge network named spreadnet with the subnet 172.18.0.0/16.

## 2. Configure spread.conf

Before running the container, edit your spread.conf file to reflect the container's IP and any other machines in the network.

```
Spread_Segment  127.0.0.255:4803 {

    localhost        172.18.0.2

    # Add other machines in the network to allow connections
    # machine1       172.18.0.3
    # machine2       172.18.0.4
}
```
Replace 172.18.0.2 with the container IP you assign.
Add entries for other machines or containers in the network if needed.

## 3. Docker Compose Example

You can use Docker Compose to simplify deployment:

```yaml
version: "3.8"

services:
  spread-toolkit:
    container_name: spread-toolkit
    image: ghcr.io/p4trickweiss/spread-toolkit:4.0.0
    ports:
      - 4803:4803
    volumes:
      - conf/spread.conf:/etc/spread/spread.conf:ro
    networks:
      spreadnet:
        ipv4_address: 172.18.0.2

networks:
  spreadnet:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16
``
