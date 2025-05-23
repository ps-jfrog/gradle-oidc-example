# Lab 3: Install JF CLI + AQL Usage

## Goals

Practice building a Java application with Gradle and JFrog CLI, and manipulate JFrog BOMs (Bill of Materials)

---
## 1. Install and configure the JFrog CLI
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

## 2. Search for artifacts with Artifactory Query Language (AQL)

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


