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