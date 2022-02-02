#!/bin/bash

DATA_PATH=$(cat .env | grep "HOST_PROMETHEUS_DATA" | cut -d'=' -f2)

mkdir -p $DATA_PATH

cp ./config/* $DATA_PATH/.

chown -R :docker $DATA_PATH