#!/bin/bash

DATA_PATH=$(cat .env | grep "HOST_ALERTMANAGER_DATA" | cut -d'=' -f2)

mkdir -p $DATA_PATH

cp ./config/alertmanager/* $DATA_PATH/.

chown -R :docker $DATA_PATH

curl -X POST http://127.0.0.1:9998/-/reload