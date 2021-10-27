#!/usr/bin/env bash

set -eu

echo "Setting download products pipeline..."

fly -t platform-automation sp -p reference-resources \
  -c ./pipelines/download-products.yml \
  --check-creds

echo "Setting sandbox reference pipeline..."

# Adds a tag to every job to tell the pipeline what remote worker to run on
# for this pipeline, the remote worker is named 'vsphere-pez' because it is in the same environment as our vSphere
fly -t platform-automation sp -p reference-pipeline \
  -c  ./pipelines/pipeline.yml \
  --var foundation=sandbox \
  --check-creds
