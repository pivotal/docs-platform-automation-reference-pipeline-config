#!/usr/bin/env bash

set -eu

echo "Setting download products pipeline..."

fly -t ci sp -p reference-resources \
  -c ~/workspace/docs-platform-automation-reference-pipeline-config/pipelines/download-products.yml \
  --check-creds

echo "Setting sandbox reference pipeline..."

# Adds a tag to every job to tell the pipeline what remote worker to run on
# for this pipeline, the remote worker is named 'openstack' because it is in the same environment as our vSphere
fly -t ci sp -p reference-pipeline \
  -c <(cat ~/workspace/docs-platform-automation-reference-pipeline-config/pipelines/pipeline.yml |
	ruby -ryaml -rjson -e "puts YAML.load(STDIN.read).to_json" |
	jq 'walk(if type == "object" and (has("source") or has("get") or has("task") or has("put")) then . + {tags: ["openstack"]} else . end)') \
  --var foundation=sandbox \
  --check-creds

#echo "Setting development reference pipeline..."

# Adds a tag to every job to tell the pipeline what remote worker to run on
# for this pipeline, the remote worker is named 'openstack' because it is in the same environment as our vSphere
#fly -t ci sp -p reference-pipeline-development \
#  -c <(cat ~/workspace/docs-platform-automation-reference-pipeline-config/pipelines/pipeline.yml |
#	ruby -ryaml -rjson -e "puts YAML.load(STDIN.read).to_json" |
#	jq 'walk(if type == "object" and (has("source") or has("get") or has("task") or has("put")) then . + {tags: ["openstack"]} else . end)') \
#  --var foundation=development \
#  --check-creds
