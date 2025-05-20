# Lab 2: Gradle Repository Creation

This lab will guide you through creating Gradle repositories in JFrog Artifactory.

## Prerequisites

- JFrog Artifactory access
- JFrog CLI installed and configured


## Create Gradle Repositories

> Come up with a ```<PROJECT_KEY>``` which will be used as prefix for all your repositories(the project key can be your USERNAME)

You'll create the following repositories for Gradle:

| Repo type | Repo key | Package type | Environment | Comment |
|---|---|---|---|---|
| LOCAL | <PROJECT_KEY>-gradle-dev-local | GRADLE | DEV | |
| LOCAL | <PROJECT_KEY>-gradle-rc-local | GRADLE | DEV | |
| LOCAL | <PROJECT_KEY>-gradle-release-local | GRADLE | PROD | |
| LOCAL | <PROJECT_KEY>-gradle-prod-local | GRADLE | PROD | |
| REMOTE | <PROJECT_KEY>-gradle-remote | GRADLE | DEV | |
| VIRTUAL | <PROJECT_KEY>-gradle-virtual | GRADLE | DEV | Includes all repos above with default deployment to <PROJECT_KEY>-gradle-rc-local |

### Using the provided script

We've provided a script to automate the repository creation process:
```
cd course-2/lab-2
```
1. Make the script executable:
   ```bash
   chmod +x create_gradle_repos.sh
   ```

2. Run the script and provide your username when prompted and theay will be used as the `<PROJECT_KEY>` prefix for the reposiotry names:
   ```bash
   ./create_gradle_repos.sh
   ```
In my test I have used the `<PROJECT_KEY>` as `sdxapp`.


### Manual repository creation using JFrog CLI

If you prefer to create repositories manually, follow these steps:

1. Use the repository creation template command to generate a JSON file describing the repository:

   ```bash
   jf rt rpt repository.json
   ```

   This is a command-line "wizard". Use the `tab` key and arrow keys to go through the wizard.
   The only thing you are required to provide is the repository's name, class (local/remote/virtual), and
   package type. Then, you may either continue providing optional information, or end the wizard using `:x`.
2. Look at the generated `repository.json` file. It contains the repository creation parameters.
3. Use the JFrog CLI to create the repository according to the created JSON file:

   ```bash
   jf rt rc repository.json
   ```

4. Now let's use some advanced capabilities by executing this command(for linux users, for windows find the equivalent or skip) :

   ```bash
   for maturity in rc release prod; do 
      jf rt rc --vars "team=$PROJECT_KEY;pkgType=gradle;maturity=$maturity;" repo-cli-template.json 
   done
   ```
For example:

1. For each local repository:
   ```bash
   # Create a configuration file
   jf rt rpt local-repo.json
   
   # Then edit it to set key, packageType, etc.
   # Then create the repository
   jf rt rc local-repo.json
   ```

2. For the remote repository:
   ```bash
   # Create a configuration file
   jf rt rpt remote-repo.json
   
   # Edit for Gradle with appropriate URL
   jf rt rc remote-repo.json
   ```

3. For the virtual repository:
   ```bash
   # Create a configuration file
   jf rt rpt virtual-repo.json
   
   # Edit to include all repos and set default deployment repo
   jf rt rc virtual-repo.json
   ```
## [OPTIONAL] Create a repository structure using the Rest API (YAML PATCH)
> with this option, you can create multiple repositories in 1 API call. However you can't :
>
> - parameterize your repo configuration
> - set the environment field

### For Gradle Repositories

1. Create the Gradle repositories:

   ```bash
      # NOTES :
      #   - update repo-api-def-all.yaml with your values
      #   - don't use -d option to specify the YAML file
      #   - environment field cannot be set (yet)

   jf rt curl \
       -X PATCH \
       -H "Content-Type: application/yaml" \
       -T gradle-repo-api-def-all.yaml  \
        "api/system/configuration"
   ```
Note: Since you cannot set the environment field for the repos , from the JFrog UI set the repository environments 
to match the above table  . 

For example:
```
sdxapp-gradle-dev-local -> DEV
sdxapp-gradle-rc-local -> DEV
sdxapp-gradle-release-local -> PROD 
```

2. Delete the Gradle repositories:

   ```bash
      jf rt curl \
       -X PATCH \
       -H "Content-Type: application/yaml" \
       -T gradle-repo-api-def-all-delete.yaml  \
        "api/system/configuration"
   ```

## [OPTIONAL] Create a repository structure using the JFrog's Terraform Provider

Follow the terraform demo in https://github.com/jfrog/trainings/tree/main/demos/advanced-repositories at the bottom.

## Verification

After creating the repositories, you can verify them in the Artifactory UI:

1. Go to your JFrog Platform UI
2. Navigate to Administration > Repositories
3. You should see your newly created repositories listed
4. Check the configuration of the virtual repository to ensure it includes all the local and remote repositories 

---
## Create permission targets via the API

> **IMPORTANT NOTE** : From Artifactory V7.72.0, the permission targets are managed by JFrog Access (internal microservice) and so the official API endpoint is ```access/api/v2/permissions```. The previous API endpoint ```artifactory/api/v2/security/permissions``` is still maintained for the moment but will be deprecated in the future (no ETA).

> Here is the [official documentation on the API](https://jfrog.com/help/r/jfrog-rest-apis/permissions)

Create the following groups from UI: 

USERNAME_developers, USERNAME_uploaders

In my test I have used the `<USERNAME_KEY>` as `sdxapp`.

Create the following permission target(s) :

Permission name | Resources | Population | Action | Comment
---|---|--- |--- |---
USERNAME_developers_pt | All Remote / "sdxapp-gradle-remote" | developers group | Read, Deploy/Cache ( which automatically adds the "Annotate" action)
USERNAME_uploaders_pt  | ( All Remote + All local) / All "sdxapp-*" | uploaders group | Read, Deploy/Cache, Delete/Overwrite



By using the following command(DONT FORGET to update sdxapp_developers_pt.json and sdxapp_uploaders_pt.json with your permission name and group name)

```bash
curl \
   -X POST \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
   -H "Content-Type: application/json" \
   -d @"sdxapp_developers_pt.json" \
"$JFROG_SAAS_URL/access/api/v2/permissions"

curl \
   -X POST \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
   -H "Content-Type: application/json" \
   -d @sdxapp_uploaders_pt.json \
"$JFROG_SAAS_URL/access/api/v2/permissions"

```

## [OPTIONAL] Create permission targets via the JFrog CLI

> relies on [```artifactory/api/v2/security/permissions```](https://jfrog.com/help/r/jfrog-rest-apis/create-permission-target)
that will be depricated in future.

Create the following permission target(s) :

Permission name | Resources | Population | Action | Comment
---|---|--- |--- |---
USERNAME_consumers  | All Remote + All local | USERNAME_uploaders group | Read, Annotate

```bash
# generate 1 permission target definition and store it into permissions.json
jf rt ptt pt-cli-template.json

# apply 1 permission target definition
jf rt ptc pt-cli-template.json
```

## Creating Scoped Tokens

> Here is the [official documentation for Tokens](https://jfrog.com/help/r/jfrog-rest-apis/access-tokens)

### Identity token

Generate an identity token (will inherit the permission related to the current user) by executing the following command

```bash
curl \
   -XPOST \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
   -d "scope=applied-permissions/user" \
$JFROG_SAAS_URL/access/api/v1/tokens
```

### Scoped token

Generate a token based on groups (will inherit the permission related to the groups) by executing the following command

```bash
curl \
   -XPOST \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
   -d "scope=applied-permissions/groups:USERNAME_uploaders" \
$JFROG_SAAS_URL/access/api/v1/tokens
```

### [OPTIONAL] Scoped token for a transient user (non existing user)

> a token can be [refreshed](https://jfrog.com/help/r/jfrog-rest-apis/refresh-token)

Generate a transient user (will inherit the permission related to the specified groups) by executing the following command

```bash
# the token will expire in 300 seconds and can be refreshed
# it has to be executed by an Admin
curl \
   -XPOST \
   -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
   -d "username=ninja" \
   -d "refreshable=true" \
   -d "expires_in=300" \
   -d "scope=applied-permissions/groups:USERNAME_uploaders" \
$JFROG_SAAS_URL/access/api/v1/tokens
```