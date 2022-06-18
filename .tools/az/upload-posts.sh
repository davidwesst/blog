#!/usr/bin/bash

CONN_STRING=$1
az storage blob upload-batch -d blog -s ./posts/ --overwrite --connection-string $CONN_STRING --pattern "[!._]*"