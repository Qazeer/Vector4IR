# Vector pipelines for Incident Response (Vector4IR)

[`Vector`](https://github.com/vectordotdev/vector) configuration files /
pipelines to parse and ship logs to `ELK` or `Splunk` (as well as the 30+
`sinks` supported by `Vector`).

100+ parsers are currently available, to process logs from various sources:
AWS, Azure / Office 365, Apache and IIS, Firewalls, Exchange and Zimbra mail
servers, vCenter and ESXi, Linux and Windows endpoints, etc.

### Execution

#### Required environnement variables

A number of environnement variables are required and are documented in each
configuration file's metadata comments (at the top of file).

An environnement variable may be set with:

  - In PowerShell, `$env:VARIABLE_NAME = "<VARIABLE_VALUE>"`.

  - In a bash shell, `export VARIABLE_NAME="<VARIABLE_VALUE>"`.

Example of required environnement variables:

```bash
# Common required environnement variables.
# In PowerShell, backslash must be escaped for paths. Example: "C:\\folder\\input_folder".
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
SPLUNK_HEC_TOKEN = "<SPLUNK_HEC_TOKEN>" # Splunk HEC token: https://docs.splunk.com/Documentation/Splunk/9.0.1/Data/UsetheHTTPEventCollector.

# Log specific environnement variables.
SOURCE_HOST = "<SOURCE_HOST>" # Hostname of the host from which the artifacts are originating, if the data is not directly present in the event.
SOURCE_TENANT = "<SOURCE_TENANT>" # AzureAD tenant from which the Azure events are originating from.
```

#### Quick usage

[As by design](https://github.com/vectordotdev/vector/issues/11095) `Vector`
does not stop itself once all inputs files are processed, `Vector` has to be
externally terminated once all events are parsed and shipped.

The `enable_api` sink can be used to enable `Vector` GraphQL API, allowing
monitoring of events throughput and throughput metrics with `vector tap` and
`vector top` respectively. This may be used to determine whenever `Vector` has
finished shipping all inputs.

```bash
# Read configuration from one or more files. Wildcard paths are supported (such as .\Parsers\Linux\*).
vector -c <CONFIG_FILE | CONFIG_FILES>

# Read configuration from files in one or more directories.
vector -C <CONFIG_FOLDER | CONFIG_FOLDERS>

# Enable Vector GraphQL API.
vector -c .\Parsers\<PARSER>,.\Sinks\enable_api.toml,.\Sinks\<SINK>

# Example to execute all the Windows parsers and send the output to Splunk.
vector -q -c .\Parsers\Windows\EZTools\*,.\Parsers\Windows\LogParser\*,.\Parsers\Windows\NirSoft\*,.\Parsers\Windows\Others\*,.\Parsers\Windows\Winlogbeat\*,.\Sinks\enable_api.toml,.\Sinks\splunk.toml
```

#### Onelinifying JSON files

Some JSON outputs, such as the ones produced by
[`DFIR-O365RC`](https://github.com/ANSSI-FR/DFIR-O365RC), are "pretty printed",
and thus not directly valid JSON objects for `Vector`.

The `Onelinifying_JSON.sh` bash script of this repository can be used to
"compact" recursively the JSON files in a folder using `jq`.

#### Testing the parsers

Before shipping events, the `assert_timestamps` sink can be used to validate
that the produced events do include a valid timestamp. If not the case, this
may be a good indicator that the parsing has failed for the given event.

```bash
vector -q -c <PARSERS>,.\Sinks\enable_api.toml,.\Sinks\assert_timestamps.toml
```

#### Sinks setup

###### ELK

`Vector` can ship events to an `Elastic` stack (`ELK`). An `Elastic` stack can
be spawned as docker containers using
[deviantony's docker-elk](https://github.com/deviantony/docker-elk) project.

`Vector` must be able to reach `elasticsearch` `HTTP API` endpoint (exposed on
port `TCP` 9200 by default). `Vector` authenticate to `ELK` using username and
password credentials.

```bash
git clone https://github.com/deviantony/docker-elk.git

docker-compose up setup

docker-compose up
```

###### Splunk

`Vector` can ship events to `Splunk`. For non-commercial uses, the
`docker-splunk` Docker container may be used.

`Vector` must be able to reach the `Splunk`'s `HTTP event collectors` service
(exposed on port `TCP` 8088 by default). Additionally, a `HTTP Event Collector`
data input must be created and its associated token configured specified to
`Vector`.

```bash
docker pull splunk/splunk:latest

# Port 8000: Splunk web interface.
# Port 8088: Splunk HTTP event collectors service.
docker run -p [<IP>:]8000:8000 -p [<IP>:]8088:8088 -e "SPLUNK_PASSWORD=<PASSWORD>" -e "SPLUNK_START_ARGS=--accept-license" splunk/splunk:latest
```
