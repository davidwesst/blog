SHELL = /bin/bash

conn_string = ${AZURE_STORAGE_CONNECTION_STRING}

run:
	./.tools/az/publish.sh "$(conn_string)" ./posts/