#!/bin/bash

CONFIG_FOLDER=prometheus
CONFIG_FILES=("alert.rules.yml" "prometheus.yml")

DOMAIN=$(cat .env | grep "PROMETHEUS_DOMAIN" | cut -d'=' -f2)
DATA_PATH=$(cat .env | grep "HOST_PROMETHEUS_DATA" | cut -d'=' -f2)

mkdir -p $DATA_PATH

for FILE in ${CONFIG_FILES[@]}; do
    if [ ! -f "./config/$CONFIG_FOLDER/$FILE" ]; then
        cp ./config/$CONFIG_FOLDER/example.$FILE ./config/$CONFIG_FOLDER/$FILE
    fi

    cp ./config/$CONFIG_FOLDER/$FILE $DATA_PATH/$FILE
done

chown -R :docker $DATA_PATH

curl -X POST http://$DOMAIN/-/reload