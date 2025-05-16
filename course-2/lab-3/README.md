# Lab 3: Gradle Build and JFrog BOMs

## Goals

Practice building a Java application with Gradle and JFrog CLI, and manipulate JFrog BOMs (Bill of Materials)

## Create build info with Gradle

> Here is the [official documentation for the JFrog CLI](https://docs.jfrog-applications.jfrog.io/)

> Here is the [official documentation for generating Build Info with Gradle](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory#gradle)

## Prerequisites (most of it had been created in lab 2)

Make sure you have completed Lab 2 and have the following repositories created:

| Repo type | Repo key | Package type | Environment | Comment |
|---|---|---|---|---|
| LOCAL | USERNAME-gradle-dev-local | GRADLE | DEV | |
| LOCAL | USERNAME-gradle-rc-local | GRADLE | DEV | |
| LOCAL | USERNAME-gradle-release-local | GRADLE | PROD | |
| LOCAL | USERNAME-gradle-prod-local | GRADLE | PROD | |
| REMOTE | USERNAME-gradle-remote | GRADLE | DEV | |
| VIRTUAL | USERNAME-gradle-virtual | GRADLE | DEV | Includes all repos above with default deployment to USERNAME-gradle-rc-local |

## Building and Publishing with Gradle

1. Navigate to the shared Java project directory:

   ```bash
   cd ../common/java
   ```

2. Ensure you have both `build.gradle` and `settings.gradle` files in your project. 
   If `settings.gradle` doesn't exist, create it with:

   ```bash
   echo "rootProject.name = 'demo'" > settings.gradle
   ```
3. Set build information environment variables:

   ```bash
   export MY_PROJ_KEY=<USERNAME> # 'export' command is for linux, for windows use 'set' command
   export JFROG_CLI_BUILD_NAME=${MY_PROJ_KEY}-gradle-app
   export JFROG_CLI_BUILD_NUMBER=1
   export JFROG_CLI_SERVER_ID=mill
   export JFROG_CLI_RELEASES_REPO=${JFROG_CLI_SERVER_ID}/${MY_PROJ_KEY}-gradle-virtual 
   export JFROG_CLI_EXTRACTORS_REMOTE=${JFROG_CLI_SERVER_ID}/${MY_PROJ_KEY}-gradle-virtual
   ```
4. Configure Gradle for JFrog Artifactory:

   ```bash
   jf gradlec \
      --repo-resolve=${MY_PROJ_KEY}-gradle-virtual \
      --repo-deploy=${MY_PROJ_KEY}-gradle-virtual \
      --server-id-resolve=${JFROG_CLI_SERVER_ID} \
      --server-id-deploy=${JFROG_CLI_SERVER_ID}

   ```





5. Build and publish the application (make sure to run this command in the directory containing both `build.gradle` and `settings.gradle`):

   ```bash
   jf gradle clean artifactoryPublish -b ./build.gradle --build-name=${JFROG_CLI_BUILD_NAME} --build-number=${JFROG_CLI_BUILD_NUMBER}
   ```

5. Collect and publish build information to Artifactory:

   ```bash
   jf rt bce  ${JFROG_CLI_BUILD_NAME} ${JFROG_CLI_BUILD_NUMBER} # Build environment collection
   jf rt bag ${JFROG_CLI_BUILD_NAME} ${JFROG_CLI_BUILD_NUMBER}
   jf rt bp  ${JFROG_CLI_BUILD_NAME} ${JFROG_CLI_BUILD_NUMBER} --detailed-summary=true # Build publish
   ```

Navigate to "Artifactory" -> "Builds", and check for your build named `<USERNAME>-gradle-app` with build number `1`.

## RBv2 (Release Bundle v2) Management from the UI

### Creation

1. From the build's screen in Artifactory, click on your build name (`<USERNAME>-gradle-app`)
2. Hover over the build number `1` and click on the 3 dots on the far right
3. Click on "Create Release Bundle"

* Release Bundle Name: `<USERNAME>-gradle-release`
* Release Bundle Version: `1.0`
* Signing Key: `jfrog_rbv2_key1`

Click "Next", then "Create".

### Promotion

In the "Promotions" sub-tab for the Release Bundle `<USERNAME>-gradle-release` ( example: `sdxapp-gradle-release`)  , Double click on the 
Release Bundle Version: `1.0`  to  navigate to the RBv2's details screen , click "Actions > Promote".

* For Signing Key, select `jfrog_rbv2_key1`.
* For Target Environment, select `PROD`.

Click "Next", ensure that the "Target Repositories" for Gradle artifacts is set properly, and click "Promote".

## RBv2 Management via API

### Creation via API

1. Go to the course-2/lab-3 folder and update the `rb_from_aql_ok.json` file to use your Gradle repositories:

   ```bash
   cd ../../lab-3/
   ```

2. Edit `rb_from_aql_ok.json` to update:
   - `release_bundle_name`: Use `<USERNAME>-gradle-rb`
   - Update the AQL to search in your Gradle repositories
   - Adjust any other repository references

3. Create the Release Bundle:

   ```bash
   curl \
       -XPOST \
       -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
       -H "Content-Type: application/json" \
       -H "X-JFrog-Signing-Key-Name: jfrog_rbv2_key1" \
       -d @"rb_from_aql_ok.json" \
   $JFROG_SAAS_URL/lifecycle/api/v2/release_bundle 
   ```

## [OPTIONAL] Promotion via API

Update `rb_promotion.json` to reference your Gradle repositories in the `included_repository_keys` field.

```bash
rb_name="<USERNAME>-gradle-rb" # Match release_bundle_name from rb_from_aql_ok.json
rb_version="1.0.0" # Match release_bundle_version from rb_from_aql_ok.json

curl \
    -XPOST \
    -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -H "X-JFrog-Signing-Key-Name: jfrog_rbv2_key1" \
    -d @"rb_promotion.json" \
$JFROG_SAAS_URL/lifecycle/api/v2/promotion/records/$rb_name/$rb_version 
```

## [OPTIONAL] Promotion via JFrog CLI

```bash
jf rbp --signing-key="jfrog_rbv2_key1" $rb_name $rb_version PROD
## NOTE - save the created_millis value for later
```
Output:
```
16:11:30 [🔵Info] Release Bundle successfully promoted
{
  "repository_key" : "release-bundles-v2",
  "release_bundle_name" : "sdxapp-gradle-rb",
  "release_bundle_version" : "1.0.0",
  "environment" : "PROD",
  "included_repository_keys" : [ "sdxapp-gradle-release-local" ],
  "excluded_repository_keys" : [ ],
  "created" : "2025-05-15T23:35:23.900Z",
  "created_millis" : 1747353204721
}
```

[Get Release Bundle v2 Version Status](https://jfrog.com/help/r/jfrog-rest-apis/get-release-bundle-v2-version-status)
```
curl -i -k -X GET "$JFROG_SAAS_URL/lifecycle/api/v2/release_bundle/statuses/$rb_name/$rb_version" \
    -H "Authorization: Bearer $JFROG_ACCESS_TOKEN"
```

## [OPTIONAL] Deletion of RBV2 promotion record via the API

> No deletion via the JFrog CLI

Note: You have to specify the creation time of the RBV2 promotion in ms, use the 

[Get Release Bundle v2 Version Promotion Details](https://jfrog.com/help/r/jfrog-rest-apis/get-release-bundle-v2-version-promotion-details)

to get that info
```
curl -i -k -X GET "$JFROG_SAAS_URL/lifecycle/api/v2/promotion/records/$rb_name/$rb_version" \
    -H "Authorization: Bearer $JFROG_ACCESS_TOKEN"
```
Output:
```
{
  "promotions" : [ {
    "status" : "COMPLETED",
    "repository_key" : "release-bundles-v2",
    "release_bundle_name" : "sdxapp-gradle-rb",
    "release_bundle_version" : "1.0.0",
    "environment" : "PROD",
    "service_id" : "jfrt@01jvam5dvet37v0ga18axy1t8d",
    "created_by" : "sureshv",
    "created" : "2025-05-15T23:53:24.721Z",
    "created_millis" : 1747353204721,
    "xray_retrieval_status" : "NOT_APPLICABLE"
  } ],
  "total" : 1,
  "limit" : 1000,
  "offset" : 0
}
```

```bash
#specify the creation time of the RBV2 promotion in ms
rb_creation_time="1747353204721"


curl \
    -XDELETE \
    -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
    -H "X-JFrog-Signing-Key-Name: jfrog_rbv2_key1" \
"$JFROG_SAAS_URL/lifecycle/api/v2/promotion/records/$rb_name/$rb_version/$rb_creation_time?async=false" 
```

## Troubleshooting

- If you encounter Gradle build errors, ensure your `settings.gradle` file exists and has the correct content
- For "build file is not part of the build defined by settings file" error, make sure you're running the command in the directory containing both files
- For JFrog CLI errors, ensure your CLI is properly configured with `jf c show`
- For repository access issues, verify you have the correct permissions
- For build info issues, check that your build name and number are correctly set 