# Lab 3: Gradle Build and JFrog BOMs

## Goals

Practice building a Java application with Gradle and JFrog CLI, and manipulate JFrog BOMs (Bill of Materials)

## Create build info with Gradle

> Here is the [official documentation for the JFrog CLI](https://docs.jfrog-applications.jfrog.io/)

> Here is the [official documentation for generating Build Info with Gradle](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory#gradle)

## Prerequisites (most of it had been created in lab 2)

Make sure you have completed Lab 2 and have the following repositories created:

In my test I have used the `<PROJECT_KEY>` as `sdxapp`.

| Repo type | Repo key | Package type | Environment | Comment |
|---|---|---|---|---|
| LOCAL | <PROJECT_KEY>-gradle-dev-local | GRADLE | DEV | |
| LOCAL | <PROJECT_KEY>-gradle-rc-local | GRADLE | DEV | |
| LOCAL | <PROJECT_KEY>-gradle-release-local | GRADLE | PROD | |
| LOCAL | <PROJECT_KEY>-gradle-prod-local | GRADLE | PROD | |
| REMOTE | <PROJECT_KEY>-gradle-remote | GRADLE | DEV | |
| VIRTUAL | <PROJECT_KEY>-gradle-virtual | GRADLE | DEV | Includes all repos above with default deployment to <PROJECT_KEY>-gradle-rc-local |

## Building and Publishing with Gradle

1. Navigate to the shared Java project directory:

   ```bash
   cd ../common/java  # you should be in course-2/common/java
   ```

2. Ensure you have both `build.gradle` and `settings.gradle` files in your project. 
   If `settings.gradle` doesn't exist, create it with:

   ```bash
   echo "rootProject.name = 'demo'" > settings.gradle
   ```
3. Set build information environment variables:

```bash
export PROJECT_KEY=sdxapp # 'export' command is for linux, for windows use 'set' command
export JFROG_CLI_BUILD_NAME=${PROJECT_KEY}-gradle-app
# Create a datetime suffix (e.g., 20250521_142530)
DATE_SUFFIX=$(date +"%Y%m%d_%H%M%S")
# Concatenate to form the unique build number
export JFROG_CLI_BUILD_NUMBER="jf_${DATE_SUFFIX}"
export JFROG_CLI_SERVER_ID=myartifactory
export JFROG_CLI_RELEASES_REPO=${JFROG_CLI_SERVER_ID}/${PROJECT_KEY}-gradle-virtual 
export JFROG_CLI_EXTRACTORS_REMOTE=${JFROG_CLI_SERVER_ID}/${PROJECT_KEY}-gradle-virtual
```
4. Configure Gradle for JFrog Artifactory:

   ```bash
   jf gradlec \
      --repo-resolve=${PROJECT_KEY}-gradle-virtual \
      --repo-deploy=${PROJECT_KEY}-gradle-virtual \
      --server-id-resolve=${JFROG_CLI_SERVER_ID} \
      --server-id-deploy=${JFROG_CLI_SERVER_ID}

   ```

5. Build and publish the application (make sure to run this command in the directory containing both `build.gradle` and `settings.gradle`):

   ```bash
   jf gradle clean artifactoryPublish -x test -b ./build.gradle --build-name=${JFROG_CLI_BUILD_NAME} --build-number=${JFROG_CLI_BUILD_NUMBER} --project=${PROJECT_KEY}
   ```

5. Collect and publish build information to Artifactory:

   ```bash
   jf rt bce ${JFROG_CLI_BUILD_NAME} ${JFROG_CLI_BUILD_NUMBER} --project=${PROJECT_KEY} # Build environment collection
   jf rt bag ${JFROG_CLI_BUILD_NAME} ${JFROG_CLI_BUILD_NUMBER} --project=${PROJECT_KEY}
   jf rt bp  ${JFROG_CLI_BUILD_NAME} ${JFROG_CLI_BUILD_NUMBER} --detailed-summary=true --project=${PROJECT_KEY} # Build publish
   ```

Navigate to "Artifactory" -> "Builds", and check for your build named `${PROJECT_KEY}-gradle-app` with build number `${JFROG_CLI_BUILD_NUMBER}`.

You will find the Published artifacts from the build is in `${PROJECT_KEY}-gradle-rc-local` repo in `DEV` Environment.

## Promote the Build

Do some QA tests and Promote the build to `${PROJECT_KEY}-gradle-dev-local` repo in `DEV` Environment ( with move option i.e `--copy=false` ).

```bash
jf rt bpr ${JFROG_CLI_BUILD_NAME} ${JFROG_CLI_BUILD_NUMBER} ${PROJECT_KEY}-gradle-dev-local --project=${PROJECT_KEY} --copy=false  --include-dependencies=false --status="QA Tests Passed" --comment="Ready for production release" --props="Testing=passed;release-version=hot-fix" 

```
To check: A new Project Environment  ${PROJECT_KEY}-QA-Tests-Passed is created named based on the "--status"  specified in the build pormote. Why ?



## Generate and upload signing keys to Artifactory:

Generate a GPG key that will be used to sign the Release Bundle and upload it to the JFrog Platform as mentioned in [generate_rbv2_gpg_key.md](generate_rbv2_gpg_key.md)

## RBv2 (Release Bundle v2) Management from the UI

### Creation

1. From the build's screen in Artifactory, click on your build name (`<PROJECT_KEY>-gradle-app`)
2. Hover over the build number `$JFROG_CLI_BUILD_NUMBER` and click on the 3 dots on the far right
3. Click on "Create Release Bundle"

* Release Bundle Name: `<PROJECT_KEY>-gradle-release`
* Release Bundle Version: `1.0`
* Signing Key: `jfrog_rbv2_key1`

Click "Next", then "Create".

### Promotion

In the "Promotions" sub-tab for the Release Bundle `<PROJECT_KEY>-gradle-release` ( example: `sdxapp-gradle-release`)  , Double click on the 
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
   - `release_bundle_name`: Use `<PROJECT_KEY>-gradle-rb`
   - Update the AQL to search in your Gradle repositories
   - Adjust any other repository references
```
# Set your project key
export PROJECT_KEY="sdxapp" # or any other project key you want

export JFROG_SAAS_URL="https://example.jfrog.io"

export rb_name="${PROJECT_KEY}-gradle-rb" # Match release_bundle_name from "rb_json/${PROJECT_KEY}_rb_from_aql_ok.json"
export rb_version="1.0.2" # Match release_bundle_version from "rb_json/${PROJECT_KEY}_rb_from_aql_ok.json"

# Generate a final JSON by substituting variables
envsubst < rb_from_aql_ok.json > "rb_json/${PROJECT_KEY}_rb_from_aql_ok.json"
envsubst < rb_promotion.json > "rb_json/${PROJECT_KEY}_rb_promotion.json"
```
3. Create the Release Bundle:
 Ref: [Release Bundle V2 APIs](https://jfrog.com/help/r/jfrog-rest-apis/release-bundle-v2-apis)

   ```bash
   curl \
       -XPOST \
       -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
       -H "Content-Type: application/json" \
       -H "X-JFrog-Signing-Key-Name: jfrog_rbv2_key1" \
       -d @"rb_json/${PROJECT_KEY}_rb_from_aql_ok.json" \
   "$JFROG_SAAS_URL/lifecycle/api/v2/release_bundle?project=${PROJECT_KEY}" 
   ```

## [OPTIONAL] Promotion via API

Update `rb_promotion.json` to reference your Gradle repositories in the `included_repository_keys` field.

```bash


curl \
    -XPOST \
    -H "Authorization: Bearer $JFROG_ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -H "X-JFrog-Signing-Key-Name: jfrog_rbv2_key1" \
    -d @"rb_json/${PROJECT_KEY}_rb_promotion.json" \
"$JFROG_SAAS_URL/lifecycle/api/v2/promotion/records/$rb_name/$rb_version?project=${PROJECT_KEY}" 
```

## [OPTIONAL] Promotion via JFrog CLI

```bash
jf rbp --signing-key="jfrog_rbv2_key1" --project=${PROJECT_KEY} $rb_name $rb_version PROD
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
curl -i -k -X GET "$JFROG_SAAS_URL/lifecycle/api/v2/release_bundle/statuses/$rb_name/$rb_version?project=${PROJECT_KEY}" \
    -H "Authorization: Bearer $JFROG_ACCESS_TOKEN"
```
Output:
```
{
  "status" : "COMPLETED"
}
```

## [OPTIONAL] Deletion of RBV2 promotion record via the API

> No deletion via the JFrog CLI

Note: You have to specify the creation time of the RBV2 promotion record in ms.  Use the 

[Get Release Bundle v2 Version Promotion Details](https://jfrog.com/help/r/jfrog-rest-apis/get-release-bundle-v2-version-promotion-details)

to get that info.
Ref: [Common Optional Query Parameters](https://jfrog.com/help/r/jfrog-rest-apis/common-optional-query-parameters)

```
curl -i -k -X GET "$JFROG_SAAS_URL/lifecycle/api/v2/promotion/records/$rb_name/$rb_version?project=${PROJECT_KEY}" \
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
"$JFROG_SAAS_URL/lifecycle/api/v2/promotion/records/$rb_name/$rb_version/$rb_creation_time?async=false&project=${PROJECT_KEY}" 
```

## Troubleshooting

- If you encounter Gradle build errors, ensure your `settings.gradle` file exists and has the correct content
- For "build file is not part of the build defined by settings file" error, make sure you're running the command in the directory containing both files
- For JFrog CLI errors, ensure your CLI is properly configured with `jf c show`
- For repository access issues, verify you have the correct permissions
- For build info issues, check that your build name and number are correctly set 