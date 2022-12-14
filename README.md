# Vector configs for Incident Response

[`Vector`](https://github.com/vectordotdev/vector) configuration files to 
send logs from various sources to `(H)ELK` or `Splunk` (as well as the
30+ `sinks` supported by `Vector`).

### Required environnement variables

A number of environnement variables are required and are documented in each 
configuration metadata comments (at the top of file).

Example of required environnement variables:

```bash
# Common required environnement variables.
INPUT_FOLDER = "<INPUT_FOLDER>"
VECTOR_TEMP_FOLDER = "<VECTOR_TEMP_FOLDER>"
INDEX = "<INDEX>"

# ELK sink specific environnement variables.
ELK_IP = "<IP>"
ELK_PORT = "<PORT>" # ELK bulk HTTP API port. Defaults to 9200.
ELK_USERNAME = "<USERNAME>"
ELK_PASSWORD = "<PASSWORD>"

# Splunk sink specific environnement variables.
SPLUNK_IP = "<IP>"
SPLUNK_PORT = "<PORT>" # Splunk HTTP Event Collector port. Defaults to 8088.
SPLUNK_HEC_TOKEN = "<SPLUNK_HEC_TOKEN>" -- Splunk HEC token: https://docs.splunk.com/Documentation/Splunk/9.0.1/Data/UsetheHTTPEventCollector.

# Log specific environnement variables
SOURCE_HOST = "<SOURCE_HOST>" # Hostname of the host from which the artifacts are originating, if the data is not directly present in the event.
SOURCE_TENANT = "<SOURCE_TENANT>" # AzureAD tenant from which the Azure events are originating from.
```

### Execution

###### Onelinifying JSON files

Some JSON outputs, such as the ones produced by
[`DFIR-O365RC`](https://github.com/ANSSI-FR/DFIR-O365RC), are "pretty printed",
and thus not directly valid JSON objects for `Vector`.

The `Onelinifying_JSON.sh` bash script of this repository can be used to
"compact" recursively the JSON files in a folder using `jq`.

### Vector execution

```bash
vector.exe [-c <CONFIG_FILE> | -C <CONFIG_FOLDER>]
```
