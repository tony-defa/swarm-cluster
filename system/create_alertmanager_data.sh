#!/bin/bash

CONFIG_FOLDER=alertmanager
CONFIG_FILES=("alertmanager.yml")

DOMAIN=$(cat .env | grep "ALERTMANAGER_DOMAIN" | cut -d'=' -f2)
DATA_PATH=$(cat .env | grep "HOST_ALERTMANAGER_DATA" | cut -d'=' -f2)

mkdir -p $DATA_PATH

for FILE in ${CONFIG_FILES[@]}; do
    if [ ! -f "./config/$CONFIG_FOLDER/$FILE" ]; then
        cp ./config/$CONFIG_FOLDER/example.$FILE ./config/$CONFIG_FOLDER/$FILE
    fi

    cp ./config/$CONFIG_FOLDER/$FILE $DATA_PATH/$FILE
done

chown -R :docker $DATA_PATH

curl -X POST http://$DOMAIN/-/reload -L -k