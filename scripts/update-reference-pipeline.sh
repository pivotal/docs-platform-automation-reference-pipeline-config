#!/usr/bin/env bash

set -eu

echo "Setting download products pipeline..."

fly -t ci sp -p reference-resources \
  -c ./pipelines/download-products.yml \
  --check-creds

echo "Setting sandbox reference pipeline..."

# Adds a tag to every job to tell the pipeline what remote worker to run on
# for this pipeline, the remote worker is named 'vsphere-pez' because it is in the same environment as our vSphere
fly -t ci sp -p reference-pipeline \
  -c <(cat ./pipelines/pipeline.yml |
	ruby -ryaml -rjson -e "puts YAML.load(STDIN.read).to_json" |
	jq 'walk(if type == "object" and (has("source") or has("get") or has("task") or has("put")) then . + {tags: ["vsphere-pez"]} else . end)') \
  --var foundation=sandbox \
  --check-creds
