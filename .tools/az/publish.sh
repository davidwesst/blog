
#!/usr/bin/bash

# dependencies: git, yq, az

# post_metadata (slug [folder name], title, description, excerpt, lastModifiedDate, publishedDate, tags)
extract_title() {
    local file=$1

    echo $(yq --front-matter=extract '.title' $file) 
}

extract_publish_date() {
    local file=$1

    echo $(date --date `yq --front-matter=extract '.date' $file`) 
}

extract_last_modified_date() {
    echo $(extract_publish_date $1)
}

extract_description() {
    local file=$1

    echo $(date --date `yq --front-matter=extract '.date' $file`) 
}

extract_tags() {
    local file=$1

    echo $(yq --front-matter=extract --output-format=csv '.tags' $file) 
}

# create array of post data
for file in $(find */index.md); do
    BLOG_TITLE=$(extract_title $file)
    BLOG_PUBLISH=$(extract_publish_date $file)
    BLOG_LAST_MODIFIED=$(extract_last_modified_date $file)
    BLOG_DESCRIPTION=$(extract_description $file)
    BLOG_TAGS=$(extract_tags $file)
    echo $BLOG_TITLE 
done

# get all existing posts <slug>/index.md and metadata
# remove entries with matching lastModifiedDate

# upload directory with upload batch
# update metadata

AZURE_STORAGE_CONNECTION_STRING=$1
# az storage blob upload-batch -d blog -s . --connection-string $AZURE_STORAGE_CONNECTION_STRING --pattern "[!.]*"