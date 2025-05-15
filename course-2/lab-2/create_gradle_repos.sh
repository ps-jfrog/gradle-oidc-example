#!/bin/bash

# Script to create Gradle repositories in JFrog Artifactory

# Prompt for username (used as project key)
read -p "Enter your USERNAME (to be used as project key): " USERNAME

if [ -z "$USERNAME" ]; then
    echo "Error: USERNAME cannot be empty."
    exit 1
fi

echo "Creating Gradle repositories with project key: $USERNAME"

# Create repo_json directory if it doesn't exist
mkdir -p repo_json
echo "JSON files will be created in the repo_json directory"

# Create local repositories
echo "Creating local repositories..."
for env in dev rc release prod; do
    cat > repo_json/gradle-${env}-local.json << EOF
{
  "key": "${USERNAME}-gradle-${env}-local",
  "rclass": "local",
  "packageType": "gradle",
  "description": "Local Gradle repository for ${env} artifacts",
  "notes": "Created by script",
  "includesPattern": "**/*",
  "excludesPattern": "",
  "repoLayoutRef": "maven-2-default",
  "xrayIndex": "true",
  "environments": "$([ "$env" == "prod" ] || [ "$env" == "release" ] && echo "PROD" || echo "DEV")"
}
EOF
    
    echo "Creating ${USERNAME}-gradle-${env}-local repository..."
    jf rt rc repo_json/gradle-${env}-local.json
done

# Create remote repository
echo "Creating remote repository..."
cat > repo_json/gradle-remote.json << EOF
{
  "key": "${USERNAME}-gradle-remote",
  "rclass": "remote",
  "packageType": "gradle",
  "description": "Remote Gradle repository proxy for Gradle plugins and dependencies",
  "notes": "Created by script",
  "url": "https://repo.maven.apache.org/maven2/",
  "includesPattern": "**/*",
  "excludesPattern": "",
  "repoLayoutRef": "maven-2-default",
  "xrayIndex": "true",
  "environments": "DEV"
}
EOF

echo "Creating ${USERNAME}-gradle-remote repository..."
jf rt rc repo_json/gradle-remote.json

# Create virtual repository
echo "Creating virtual repository..."
cat > repo_json/gradle-virtual.json << EOF
{
  "key": "${USERNAME}-gradle-virtual",
  "rclass": "virtual",
  "packageType": "gradle",
  "description": "Virtual Gradle repository",
  "notes": "Created by script",
  "includesPattern": "**/*",
  "excludesPattern": "",
  "repositories": "${USERNAME}-gradle-dev-local,${USERNAME}-gradle-rc-local,${USERNAME}-gradle-release-local,${USERNAME}-gradle-prod-local,${USERNAME}-gradle-remote",
  "defaultDeploymentRepo": "${USERNAME}-gradle-rc-local",
  "repoLayoutRef": "maven-2-default",
  "environments": "DEV"
}
EOF

echo "Creating ${USERNAME}-gradle-virtual repository..."
jf rt rc repo_json/gradle-virtual.json

echo "Repository creation completed."
echo ""
echo "The following repositories have been created:"
echo "- ${USERNAME}-gradle-dev-local"
echo "- ${USERNAME}-gradle-rc-local"
echo "- ${USERNAME}-gradle-release-local"
echo "- ${USERNAME}-gradle-prod-local"
echo "- ${USERNAME}-gradle-remote"
echo "- ${USERNAME}-gradle-virtual"
echo ""
echo "Virtual repository ${USERNAME}-gradle-virtual includes all repositories."
echo "Default deployment repository is set to ${USERNAME}-gradle-rc-local."
echo ""
echo "All JSON configuration files have been saved in the repo_json directory." 