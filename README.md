# GitHub Actions OIDC Integration with JFrog Platform

This document explains how to set up GitHub Actions with JFrog Platform using OIDC (OpenID Connect) authentication.

## Prerequisites

1. A JFrog Platform instance (Artifactory)
2. GitHub repository with admin access
3. The following repositories configured in your JFrog Platform:
   - sdx-app-gradle-dev-local
   - sdx-app-gradle-rc-local
   - sdx-app-gradle-release-local
   - sdx-app-gradle-remote
   - sdx-app-gradle-virtual (virtual repository containing the above repositories)

## Required GitHub Variables and Secrets

### GitHub Variables
Configure these in your repository's Settings > Secrets and variables > Actions > Variables:

1. `JF_NAME`: Your JFrog instance name (e.g., if your JFrog URL is https://mycompany.jfrog.io, then JF_NAME would be "mycompany")

### GitHub Secrets
Configure these in your repository's Settings > Secrets and variables > Actions > Secrets:

1. `GITHUB_TOKEN`: This is automatically provided by GitHub Actions
2. `RBV2_SIGNING_KEY`: (Optional) If you're using Release Bundle v2 signing. See [Create Signing Keys for Release Bundles v2](https://jfrog.com/help/r/jfrog-artifactory-documentation/create-signing-keys-for-release-bundles-v2)

## JFrog OIDC Provider Setup

1. Log in to your JFrog Platform
2. Go to Administration > General Management > Manage Integrations
3. Create a new OIDC provider for GitHub Actions
4. Configure the following:
   - Provider Name: Set this in your GitHub Variables as `JF_OIDC_PROVIDER_NAME`
   <!-- - Client ID: Your GitHub OAuth App client ID
   - Client Secret: Your GitHub OAuth App client secret -->
   - Issuer/Provider URL: https://token.actions.githubusercontent.com
   - Required Claims:
     - `sub`: `repo:${GITHUB_REPOSITORY}:ref:refs/heads/${GITHUB_REF#refs/heads/}`
     - `aud`: Your GitHub OAuth App client ID

## Repository Configuration

The workflow uses the following repository configuration:
- Resolves dependencies from: `sdx-app-gradle-virtual`
- Deploys artifacts to: `sdx-app-gradle-dev-local`

## Workflow Environment Variables

The workflow uses these environment variables:
- `JAVA_PROVIDER`: 'corretto'
- `JAVA_VERSION`: '17'
- `JF_RT_URL`: https://${{vars.JF_NAME}}.jfrog.io
- `RT_REPO_GRADLE_VIRTUAL`: "sdx-app-gradle-virtual"
- `RT_REPO_GRADLE_DEV_LOCAL`: "sdx-app-gradle-dev-local"
- `BUILD_NAME`: "gradle-oidc"
- `BUILD_ID`: "ga-${{github.run_number}}"

## Workflow Steps

The GitHub Actions workflow performs the following steps:
1. Sets up JFrog CLI with OIDC authentication
2. Sets up JDK 17 (Corretto)
3. Configures Gradle build
4. Builds and publishes the project
5. Collects build environment information
6. Publishes build info
7. Performs build scan

## Additional Resources

- [JFrog GitHub Actions Documentation](https://jfrog.com/help/r/jfrog-cli/github-actions-integration)
- [JFrog OIDC Integration Guide](https://jfrog.com/help/r/jfrog-platform-administration/oidc-integration)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [JFrog CLI Setup Action](https://github.com/marketplace/actions/setup-jfrog-cli) 