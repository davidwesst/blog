SHELL = /bin/bash

conn_string = ${AZURE_STORAGE_CONNECTION_STRING}

run:
	@echo "Running publish.sh..."
	@./.tools/publish.sh "$(conn_string)" ./posts/