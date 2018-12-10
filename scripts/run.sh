#!/bin/bash

[ -z "$POEDITOR_API_TOKEN" ] && echo "Please set the \"poeditor_api_token\" secret" && exit 1;
[ -z "$POEDITOR_PROJECT_ID" ] && echo "Please set the \"poeditor_project_id\" secret" && exit 1;
[ -z "$PLUGIN_PO_FILES_PATH" ] && echo "Please set the \"po_files_path\" parameter" && exit 1;

#----
## Format 'xx-xx' or 'xx' to xx-XX
## @param $1 string language code. Example: en-gb or fr or fr-FR
#----
formatPoFilename () {
    if [[ $1 != *"-"* ]]; then
        language="$1"
        region="$1"
    else
        language=${1%%-*}
        region=${1#*-}
    fi

    regionUpper=`echo "${region}" | tr '[a-z]' '[A-Z]'`

    echo "$language-$regionUpper"
}

# Get languages list for the specified project
LANGUAGES=$(curl -X POST https://api.poeditor.com/v2/languages/list \
     -d api_token="${POEDITOR_API_TOKEN}" \
     -d id="${POEDITOR_PROJECT_ID}")

# loop through available languages for the app
for row in $(echo "${LANGUAGES}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 -d | jq -r ${1}
    }

   languagesJson=$(_jq '.languages')
done

# loop through languages to get the code E.g. en-gb, fr, en-us, …
languagesArray=()
for row2 in $(echo "${languagesJson}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row2} | base64 -d | jq -r ${1}
    }

   # Storing language codes in array
   languagesArray+=( $(_jq '.code') )
done

# Loop through language code array - Curl creating a file url to get the po
poFilesUrls=()
for element in "${languagesArray[@]}"
do
    # Generate a link to download the language po file
    poFile=$(curl -X POST https://api.poeditor.com/v2/projects/export \
     -d api_token="${POEDITOR_API_TOKEN}" \
     -d id="${POEDITOR_PROJECT_ID}" \
     -d language="${element}" \
     -d type="po")

    poFileUrl=$( echo "${poFile}"| jq -r '.result.url' )

    poFilename=`formatPoFilename $element`

    # Download and store the file
    curl -0 "$poFileUrl" -o "$PLUGIN_PO_FILES_PATH$poFilename".po
done

# Display files downloaded
cd "$PLUGIN_PO_FILES_PATH"
ls -l