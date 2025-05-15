# Lab 2: Gradle Repository Creation

This lab will guide you through creating Gradle repositories in JFrog Artifactory.

## Prerequisites

- JFrog Artifactory access
- JFrog CLI installed and configured

## Create Gradle Repositories

You'll create the following repositories for Gradle:

| Repo type | Repo key | Package type | Environment | Comment |
|---|---|---|---|---|
| LOCAL | <USERNAME>-gradle-dev-local | GRADLE | DEV | |
| LOCAL | <USERNAME>-gradle-rc-local | GRADLE | DEV | |
| LOCAL | <USERNAME>-gradle-release-local | GRADLE | PROD | |
| LOCAL | <USERNAME>-gradle-prod-local | GRADLE | PROD | |
| REMOTE | <USERNAME>-gradle-remote | GRADLE | DEV | |
| VIRTUAL | <USERNAME>-gradle-virtual | GRADLE | DEV | Includes all repos above with default deployment to <USERNAME>-gradle-rc-local |

### Using the provided script

We've provided a script to automate the repository creation process:
```
cd course-2/lab-2
```
1. Make the script executable:
   ```bash
   chmod +x create_gradle_repos.sh
   ```

2. Run the script and provide your username when prompted:
   ```bash
   ./create_gradle_repos.sh
   ```

### Manual repository creation using JFrog CLI

If you prefer to create repositories manually, follow these steps:

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

## Verification

After creating the repositories, you can verify them in the Artifactory UI:

1. Go to your JFrog Platform UI
2. Navigate to Artifactory > Artifacts
3. You should see your newly created repositories listed
4. Check the configuration of the virtual repository to ensure it includes all the local and remote repositories 