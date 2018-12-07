# Drone poeditor po files download

[![Build Status](https://travis-ci.org/maximelebastard/drone-po-editor-plugin.svg?branch=master)](https://travis-ci.org/maximelebastard/drone-po-editor-plugin)

Lightweight drone plugin to download po files from poeditor for a specified project.

## Usage

```yaml
pipeline:
  get-po-files:
    image: maximelebastard/drone-po-editor-plugin
    po_files_path: ./maybe/a/subdirectory/of/the/project
    secrets:
      - POEDITOR_API_TOKEN
      - POEDITOR_PROJECT_ID
    when:
      event: deployment
```


## Parameters

* **po_files_path** : (Optional - default is ".") any subdirectory of the project that contains the po files


## Secrets

POEditor gives you an API token to access their API

You can see this API token as well as the projects id in your account / API Access