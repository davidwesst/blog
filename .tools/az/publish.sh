#!/bin/bash

# dependencies: yq, jq, az



# TODO: process and validate parameters
AZURE_STORAGE_CONNECTION_STRING=$1
DIRECTORY=.
if [ -n $2 ]; then
	DIRECTORY=$2
fi

extract_slug() {
	local file=$1

	echo $(echo $file | sed 's/[/]index.md//')
}

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

    echo $(yq --front-matter=extract '.description' $file) 
}

extract_tags() {
    local file=$1

    echo $(yq --front-matter=extract --output-format=csv '.tags' $file) 
}

publish_post() {
	local file=$1

	# check if post already exists
	is_new=$(is_post_new $file)

	if [ $is_new == 1 ]; then
		# if not new, check if changed
		is_changed=$(is_post_different $file)
	fi

	if [[ $is_new == 0 || $is_changed == 0 ]]; then
		echo "Uploading $file..."
		upload_post $file 
	fi
}

upload_post() {
	local file=$1

	# TODO: do error handling in each extract method, starting with date commands
	BLOG_SLUG=$(extract_slug $file)
    BLOG_TITLE=$(extract_title $file)
    BLOG_PUBLISH=$(extract_publish_date $file)
    BLOG_LAST_MODIFIED=$(extract_last_modified_date $file)
    BLOG_DESCRIPTION=$(extract_description $file)
    BLOG_TAGS=$(extract_tags $file)
	
	echo "$BLOG_SLUG start!"

	# upload directory contents
	az storage blob upload-batch \
		--destination blog/$BLOG_SLUG \
		--source $BLOG_SLUG \
		--connection-string $AZURE_STORAGE_CONNECTION_STRING \
		--overwrite \
		--no-progress \
		--pattern "[!._]*" > /dev/null 2>&1

	# update metadata on index.md file
	az storage blob metadata update \
		--name $file \
		--container-name "blog" \
		--connection-string $AZURE_STORAGE_CONNECTION_STRING \
		--metadata slug=$BLOG_SLUG title="$BLOG_TITLE" publishDate="$BLOG_PUBLISH" description="$BLOG_DESCRIPTION" tags="$BLOG_TAGS" \
		> /dev/null 2>&1

	echo "$BLOG_SLUG complete!"
}

is_post_new() {
	local file=$1
	local retcode=1

	# if exists, return 1
	result=`az storage blob exists --container-name blog --name $file --connection-string $AZURE_STORAGE_CONNECTION_STRING \
				| jq --raw-output '.exists'`
	if [ $result == "false" ]; then
		retcode=0
	fi

	echo $retcode
}

is_post_different() {
	local file=$1
	local retcode=0

	# calculate md5 of file locally
	# reference: https://galdin.dev/blog/md5-has-checks-on-azure-blob-storage-files/
	localmd5=`openssl dgst -md5 -binary $file | base64`
	remotemd5=`az storage blob show --container-name blog --name $file --connection-string $AZURE_STORAGE_CONNECTION_STRING \
				| jq --raw-output '.properties.contentSettings.contentMd5'`

	if [ $localmd5 == $remotemd5 ]; then
		retcode=1
	fi

	echo $retcode
}

# TODO: extract categories
# TODO: extract excerpt from post content
# TODO: calculate reading time and add as metadata

# move into directory
pushd $DIRECTORY 1> /dev/null

# create array of post data
for file in $(find */index.md); do
	publish_post $file &
done

wait
# TODO: delete posts that are no longer present

# pop directory
popd 1> /dev/null
