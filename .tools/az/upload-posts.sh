#!/usr/bin/bash

AZURE_STORAGE_CONNECTION_STRING=$1
az storage blob upload-batch -d blog -s . --connection-string $AZURE_STORAGE_CONNECTION_STRING --pattern "[!.]*"