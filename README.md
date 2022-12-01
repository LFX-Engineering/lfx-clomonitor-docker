# lfx-clomonitor-docker

A docker image and documentation for building and running the CLO Monitor Linter tool. The docker is a simple container
that includes
both the [the clomonitor-linter tool](https://github.com/cncf/clomonitor) and the
companion [OSSF scorecard tool](https://github.com/ossf/scorecard).

## Build Docker Image

To build the docker image, run the following command:

```bash
docker build --tag lfx-clomonitor-docker:latest .
```

## Pull Docker Image

To pull the prebuilt docker image from this repo, run the following command:

```bash
docker pull ghcr.io/LFX-Engineering/lfx-clomonitor-docker:latest
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
  lfx-clomonitor-docker:latest \
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

In the following example, the `clomonitor-pr.ymal` file is placed in the repository `.github/workflows` directory. The
workflow is triggered when a pull request is created or updated. The workflow will run the CLO Monitor linter tool and
generate a report.

To summarize, the workflow does the following:

- Runs when a pull request is created with the target of the `main` branch. 
- A workflow job is created to run the CLO Monitor linter tool. The job leverages the pre-built lfx-clomonitor-docker
  container
- The container must have the GITHUB_TOKEN environment variable set as the tool requires this to communicate to the
  GitHub API.
- The workspace volume is mounted to the container so the tool can access the repository files.
- The repository is checked out to the workspace volume.
- The tool is executed with the options of where the local repostiory is located, the repository URL. In this case, the
  default check-set options are used since no check-set options are specified.
- After the job runs, the results will be displayed in the GitHub Actions log.
- The `continue-on-error` option is used as we want the workflow to continue even if the CLO Monitor linter tool reports
  a failing grade.

```yaml
---
name: CLO Monitor Report

on:
  # https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions
  pull_request:
    branches:
      - main

jobs:
  clo-monitor-report:
    environment: dev # optional, used to pull environment variables from the specified environment configuration
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/lfx-engineering/lfx-clomonitor-docker:latest
      env:
        # Must have a GitHub token with read access to the repository
        GITHUB_TOKEN: ${{ secrets.CLOMONITOR_GITHUB_TOKEN }}
      volumes:
        - ${{ github.workspace }}:/${{ github.event.repository.name }}
    steps:
      - uses: actions/checkout@v3
      - name: Run CLO Monitor
        continue-on-error: true
        working-directory: /app
        run: |
          /app/clomonitor-linter --path /${{ github.event.repository.name }} --url ${{ github.server_url }}/${{ github.repository }}
```

## License

Copyright The Linux Foundation and each contributor to LFX.

This project’s source code is licensed under the MIT License. A copy of the license is available in LICENSE.

This project’s documentation is licensed under the Creative Commons Attribution 4.0 International License \(CC-BY-4.0\).
A copy of the license is available in LICENSE-docs.
