# Lab: Artifact management basics

## Goals

Perform basics actions via the UI & API regarding artifacts management

## Pre requisites

Create the following repository via the UI :

Repo type | Repo key | Package type | Environment | Comment
---|---|--- |---|---
LOCAL | [USERNAME]-generic-test-local | GENERIC | DEV |

## Upload / Download via the REST API

1. Upload a random file

```bash
echo "Hello World" > test.txt

curl \
   -X PUT \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
   -d "@test.txt" \
$JFROG_SAAS_URL/artifactory/<USERNAME>-generic-test-local/test.txt
```

2. Delete the file from your local machine.
3. Download the file using the REST API:

```bash
curl \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
$JFROG_SAAS_URL/artifactory/<USERNAME>-generic-test-local/test.txt
```
---
## Install and configure the JFrog CLI
1. Install the [JFrog CLI](https://jfrog.com/getcli/)
```
curl -fkL https://install-cli.jfrog.io | sh 
```
2. Configure the JFrog CLI with your Artifactory instance as mentioned in [jfrog-cli/authentication](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/authentication):

Option 1: Interactive configuration:

- Configure CLI that point to JFrog Instance ``jf config add --interactive`` or ``jf c add --interactive``
    - Choose a server ID: ```${{unique name}}```
    - JFrog platform URL: ```https://{{host}}.jfrog.io```
    - JFrog access token (Leave blank for username and password/API key): ```${{access_token}}```
        - Create access token from UI ``Administration`` -> ``Identity and Access`` -> ``Access Tokens``
    - Is the Artifactory reverse proxy configured to accept a client certificate (y/n) [n]?: ``n``


- Use newly created config ``jf config use myartifactory``



or

Option 2: Browser Interactive configuration:

```
jf c add --interactive=true --url=<ARTIFACTORY BASE URL> --user=adminuser myartifactory

```

- Healthcheck ``jf rt ping``


---
## Upload / Download via the JFrog CLI

1. Create multiple text files

```bash
# This is a Linux command. If you're using Windows you can create the files manually or find the Windows equivalent - what takes faster
for d in monday tuesday wednesday thursday; do echo "Hello $d \!" > ${d}.txt ; done
```

2. Upload multiple files to the repository using the JFrog CLI:

```bash
jf rt upload "*.txt" <USERNAME>-generic-test-local/cli-tests/
```

3. Download the content of a folder from the repository into your local machine:

```bash
jf rt download <USERNAME>-generic-test-local/cli-tests/ .
```

## Apply properties via the UI

1. In the artifacts browser view, navigate to the file you just uploaded.
2. Navigate to the `Properties` tab.
3. Add the following properties :
   + `app.name` with the value `snake`
   + `app.version` with the value `1.0.0`

## [OPTIONAL] Apply properties via the REST API

Assign the following properties to a file

```bash
curl \
   -X PUT \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
"$JFROG_SAAS_URL/artifactory/api/storage/<USERNAME>-generic-test-local/cli-tests/monday.txt?properties=os=win,linux;qa=done"
```

## [OPTIONAL] Apply properties via the JFrog CLI

Assign the following properties to a file

+ runtime.deploy.datetime=20240219_08000
+ runtime.deploy.account=robot_sa

by executing the following command (don't forget to update the repository key)

```bash
jf rt sp "<USERNAME>-generic-test-local/test.txt" "runtime.deploy.datetime=20240219_08000;runtime.deploy.account=robot_sa"
```

## Search for artifacts with Artifactory Query Language (AQL)

> Here is the [official documentation for AQL](https://jfrog.com/help/r/jfrog-rest-apis/artifactory-query-language)

1. Update the following files with your own repository key

+ **query-aql-properties-rest.txt**
+ **query-aql-cli.json**

Execute the following commands

```bash

# Run an AQL query via the API
jf rt curl -XPOST -H "Content-type: text/plain" api/search/aql -d"@query-aql-properties-rest.txt"

# Run an AQL query via the JFrog CLI
jf rt s --spec="query-aql-cli.json"
```

## [OPTIONAL] Search for artifacts with GraphQL

> Here is the [official documentation for GraphQL](https://jfrog.com/help/r/jfrog-rest-apis/graphql)

```bash
# the JFrog CLI rt curl command doesn't target metadata/api
# we have to use curl
curl \
   -XPOST \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
   -H "Content-Type: application/json" \
   -d "@query-graphql.json" \
"$JFROG_SAAS_URL/metadata/api/v1/query" 
```

### [OPTIONAL] GraphiQL

1. In your browser, go to  `$JFROG_SAAS_URL/metadata/api/v1/query/graphiql`and specify your access token
2. Extract the query from the JSON file  '{"query" : "<QUERY_TO_EXTRACT>"}  from `../../demos/basics-search/query-graphql.json`
3. Paste it in the query editor and execute it


