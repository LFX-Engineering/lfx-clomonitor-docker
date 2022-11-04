#!/usr/bin/env bash
# Copyright The Linux Foundation and each contributor to LFX.
# SPDX-License-Identifier: MIT

# 1. Before running this, clone the repository or ensure it is available in the local filesystem
# 2. Adjust the volume mount to point to the local repository folder and match it with the --path parameter
# 3. Adjust the --url parameter to ensure it matches the repository URL
# 4. Adjust the --check-set parameter(s) to match the check-set configuration you want to run
# 5. Set the GITHUB_TOKEN environment variable. This is needed to allow the tool to access the GitHub API.

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
