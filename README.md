# lfx-clomonitor-docker

A docker image and documentation for building and running the CLO Monitor Linter tool. The docker is a simple container
that includes
both the [the clomonitor-linter tool](https://github.com/cncf/clomonitor) and the
companion [OSSF scorecard tool](https://github.com/ossf/scorecard).

## Build Docker Image

To build the docker image, run the following command:

```bash
docker build --tag lfx-clomonitor:latest .
```

## Run Docker Image

The docker image will need to be run with the following environment
variables:

* `GITHUB_TOKEN` - A GitHub token with read access to the repository

Additionally, the docker image will need to be run with the following arguments:

* `--path` - the path to the cloned repository
* `--url` - The repository URL to run the linter against
* `--check-set` - The (optional) check set options to run the linter against, see
  the [configuration page](https://github.com/cncf/clomonitor/blob/main/docs/checks.md#checks)

Below are some examples of running the docker image:

```bash
# Available CLO Monitor check-set options:
#   --check-set code
#   --check-set code-lite
#   --check-set community
#   --check-set docs
#
# Full Usage is:
# Usage: clomonitor-linter [OPTIONS] --path <PATH> --url <URL>
#
# Options:
#      --path <PATH>              Repository local path (used for checks that can be done locally)
#      --url <URL>                Repository url [https://github.com/org/repo] (used for some GitHub remote checks)
#      --check-set <CHECK_SET>    Sets of checks to run [default: code community] [possible values: code, code-lite, community, docs]
#      --pass-score <PASS_SCORE>  Linter pass score [default: 75]
#      --format <FORMAT>          Output format [default: table] [possible values: json, table]
#  -h, --help                     Print help information
#  -V, --version                  Print version information
# Ref: https://clomonitor.io/docs/topics/checks/

docker run -it \
  -e GITHUB_TOKEN="${GITHUB_TOKEN}" \
  -v "${PWD}/data:/data" \
  lfx-clomonitor:latest \
  /app/clomonitor-linter \
  --path /data/easycla \
  --url https://github.com/communitybridge/easycla \
  --check-set code \
  --check-set community \
  --check-set docs
```

Also, there is a simple bash script to launch the docker image, see the [run-example.sh](run-example.sh) script.

## Configuration

The CLO Monitor linter tool is configured via the `--check-set` command line options. For more information on the
configuration options, see the [configuration page](https://github.com/cncf/clomonitor/blob/main/docs/checks.md#checks).

## GitHub Token Issues

A valid GitHub token is required to run the CLO Monitor Linter tool. If you are running into issues with the GitHub
token, please refer
to [the following documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
.

Generally, if the token is invalid or the token does not have access to the repository, the following error may be
displayed:

```code
Error: repository field not found in github medatata response
```

## Reports

The resulting output from the CLO Monitor linter tool can be in either text or
JSON output. Use the `--format` command line option to set the output format.
Here are two report examples:

- report example in the [text format](report-example.md)
- report example in the [json format](report.json)

## CI/CD Integration

The CLO Monitor linter tool can be integrated into a CI/CD pipeline. The easiest way to integrate the tool is to add
a step in the CI/CD pipeline to run the docker image to generate the report. The results of the report can then be
reviewed or used to fail the CI/CD pipeline.

### GitHub Actions Integration Example

The following is an example of a GitHub Actions workflow that runs the CLO Monitor linter tool.

In the following example, the YAML file is placed in the repository `.github/workflows` directory. The workflow is
triggered when a pull request is created or updated. The workflow will run the CLO Monitor linter tool and generate
a report.

```yaml
---
name: CLO Monitor Report

on:
  # https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions
  pull_request:
    branches:
      - main

env:
  STAGE: prod
  REGION: us-east-2
  REPOSITORY: lfx-clomonitor
  ECR_HOST: ${{secrets.AWS_ACCOUNT_ID}}.dkr.ecr.us-east-2.amazonaws.com

jobs:
  clo-monitor-report:
    runs-on: ubuntu-latest
    environment: dev
    steps:
      - uses: actions/checkout@v3
#      - name: Configure AWS Credentials
#        uses: aws-actions/configure-aws-credentials@v1
#        with:
#          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
#          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
#          aws-region: us-east-2
#          role-duration-seconds: 900

# TODO: Uncomment these lines after we have published the ECR image to the repo
#      - name: Pull ECR Image
#        run: |
#          echo "Showing caller identity..."
#          aws sts get-caller-identity
#          echo "Logging into ECR..."
#          aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_HOST}/${REPOSITORY}
#
#          echo "Pulling image with tag: ${ECR_HOST}/${REPOSITORY}:latest"
#          docker pull ${ECR_HOST}/${REPOSITORY}:latest

```

## License

Copyright The Linux Foundation and each contributor to LFX.

This project’s source code is licensed under the MIT License. A copy of the license is available in LICENSE.

This project’s documentation is licensed under the Creative Commons Attribution 4.0 International License \(CC-BY-4.0\).
A copy of the license is available in LICENSE-docs.
