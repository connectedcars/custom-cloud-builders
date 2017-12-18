#!/bin/bash

set -e

if [[ ! -n "$KMS_KEY_NAME" ]]; then
    echo "KMS_KEY_NAME needs to be set"
    exit 255
fi

PROJECT=$(echo $KMS_KEY_NAME | cut -f1 -d'/')
LOCATION=$(echo $KMS_KEY_NAME | cut -f2 -d'/')
KEYRING=$(echo $KMS_KEY_NAME | cut -f3 -d'/')
KEY=$(echo $KMS_KEY_NAME | cut -f4 -d'/')

echo gcloud --project $PROJECT kms decrypt --location=$LOCATION --keyring=$KEYRING --key=$KEY --ciphertext-file=/root/.ssh/id_rsa.enc --plaintext-file=/root/.ssh/id_rsa

gcloud --project $PROJECT kms decrypt --location=$LOCATION --keyring=$KEYRING --key=$KEY --ciphertext-file=/root/.ssh/id_rsa.enc --plaintext-file=/root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa