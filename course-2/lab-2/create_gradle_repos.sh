#!/bin/bash

# Script to create Gradle repositories in JFrog Artifactory

# Prompt for PROJECT_KEY (used as project key)
read -p "Enter your PROJECT_KEY (to be used as project key): " PROJECT_KEY

if [ -z "$PROJECT_KEY" ]; then
    echo "Error: PROJECT_KEY cannot be empty."
    exit 1
fi

echo "Creating Gradle repositories with project key: $PROJECT_KEY"

# Create repo_json directory if it doesn't exist
mkdir -p repo_json
echo "JSON files will be created in the repo_json directory"

# Create local repositories
echo "Creating local repositories..."
for env in dev rc release prod; do
    cat > repo_json/gradle-${env}-local.json << EOF
{
  "key": "${PROJECT_KEY}-gradle-${env}-local",
  "rclass": "local",
  "packageType": "gradle",
  "description": "Local Gradle repository for ${env} artifacts",
  "notes": "Created by script",
  "includesPattern": "**/*",
  "excludesPattern": "",
  "repoLayoutRef": "maven-2-default",
  "xrayIndex": "true",
  "projectKey": "${PROJECT_KEY}",
  "environments": "$([ "$env" == "prod" ] || [ "$env" == "release" ] && echo "PROD" || echo "DEV")"
}
EOF
    
    echo "Creating ${PROJECT_KEY}-gradle-${env}-local repository..."
    jf rt rc repo_json/gradle-${env}-local.json
done

# Create remote repository
echo "Creating remote repository..."
cat > repo_json/gradle-remote.json << EOF
{
  "key": "${PROJECT_KEY}-gradle-remote",
  "rclass": "remote",
  "packageType": "gradle",
  "description": "Remote Gradle repository proxy for Gradle plugins and dependencies",
  "notes": "Created by script",
  "url": "https://repo.maven.apache.org/maven2/",
  "includesPattern": "**/*",
  "excludesPattern": "",
  "repoLayoutRef": "maven-2-default",
  "xrayIndex": "true",
  "projectKey": "${PROJECT_KEY}",
  "environments": "DEV"
}
EOF

echo "Creating ${PROJECT_KEY}-gradle-remote repository..."
jf rt rc repo_json/gradle-remote.json

# Create virtual repository
echo "Creating virtual repository..."
cat > repo_json/gradle-virtual.json << EOF
{
  "key": "${PROJECT_KEY}-gradle-virtual",
  "rclass": "virtual",
  "packageType": "gradle",
  "description": "Virtual Gradle repository",
  "notes": "Created by script",
  "includesPattern": "**/*",
  "excludesPattern": "",
  "repositories": "${PROJECT_KEY}-gradle-dev-local,${PROJECT_KEY}-gradle-rc-local,${PROJECT_KEY}-gradle-release-local,${PROJECT_KEY}-gradle-prod-local,${PROJECT_KEY}-gradle-remote",
  "defaultDeploymentRepo": "${PROJECT_KEY}-gradle-rc-local",
  "repoLayoutRef": "maven-2-default",
  "projectKey": "${PROJECT_KEY}",
  "environments": "DEV"
}
EOF

echo "Creating ${PROJECT_KEY}-gradle-virtual repository..."
jf rt rc repo_json/gradle-virtual.json

echo "Repository creation completed."
echo ""
echo "The following repositories have been created:"
echo "- ${PROJECT_KEY}-gradle-dev-local"
echo "- ${PROJECT_KEY}-gradle-rc-local"
echo "- ${PROJECT_KEY}-gradle-release-local"
echo "- ${PROJECT_KEY}-gradle-prod-local"
echo "- ${PROJECT_KEY}-gradle-remote"
echo "- ${PROJECT_KEY}-gradle-virtual"
echo ""
echo "Virtual repository ${PROJECT_KEY}-gradle-virtual includes all repositories."
echo "Default deployment repository is set to ${PROJECT_KEY}-gradle-rc-local."
echo ""
echo "All JSON configuration files have been saved in the repo_json directory." 