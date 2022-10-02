#!/bin/bash

CONFIG_FOLDER=traefik
CONFIG_FILES=("http.yml" "tls.yml")

DATA_PATH=$(cat .env | grep "HOST_TRAEFIK_PATH" | cut -d'=' -f2)

mkdir -p $DATA_PATH/dynamic

for FILE in ${CONFIG_FILES[@]}; do
    if [ ! -f "./config/$CONFIG_FOLDER/$FILE" ]; then
        cp ./config/$CONFIG_FOLDER/example.$FILE ./config/$CONFIG_FOLDER/$FILE
    fi

    cp ./config/$CONFIG_FOLDER/$FILE $DATA_PATH/dynamic/$FILE
done

SECRETS_FILES=("users.txt" "acme.json")

for FILE in ${SECRETS_FILES[@]}; do
	if [ ! -f "$DATA_PATH/$FILE" ]; then
		touch $DATA_PATH/$FILE
		chmod 600 $DATA_PATH/$FILE
	else
		echo "$FILE file already exists and could contain sensitive data. Modify '$DATA_PATH/$FILE' at your own risk."
	fi
done

chown -R :docker $DATA_PATH