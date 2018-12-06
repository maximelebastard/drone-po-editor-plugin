#!/bin/bash
LANGUAGES=$(curl -X POST https://api.poeditor.com/v2/languages/list \
     -d api_token="${PLUGIN_POEDITOR_API_TOKEN}" \
     -d id="${PLUGIN_POEDITOR_PROJECT_ID}")

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
   POFILE=$(curl -X POST https://api.poeditor.com/v2/projects/export \
     -d api_token="${PLUGIN_POEDITOR_API_TOKEN}" \
     -d id="${PLUGIN_POEDITOR_PROJECT_ID}" \
     -d language="${element}" \
     -d type="po")

    POFILEURL=$( echo "${POFILE}"| jq -r '.result.url' )

    curl -0 "$POFILEURL" -o "$element".po
done