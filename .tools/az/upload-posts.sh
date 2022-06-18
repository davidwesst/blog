#!/usr/bin/bash

CONN_STRING=$1
az storage blob upload-batch -d blog -s . --overwrite --connection-string $CONN_STRING --pattern "[!.]*"