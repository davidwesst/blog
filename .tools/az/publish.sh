
#!/usr/bin/bash

# dependencies: git, yq, az

# post_metadata (slug [folder name], title, description, excerpt, lastModifiedDate, publishedDate, tags)

# create array of post data
for file in $(find */index.md); do
    git log -n 1 --pretty="$(echo $file) %ci" $file
done

# get all existing posts <slug>/index.md and metadata
# remove entries with matching lastModifiedDate

# upload directory with upload batch
# update metadata

AZURE_STORAGE_CONNECTION_STRING=$1
# az storage blob upload-batch -d blog -s . --connection-string $AZURE_STORAGE_CONNECTION_STRING --pattern "[!.]*"