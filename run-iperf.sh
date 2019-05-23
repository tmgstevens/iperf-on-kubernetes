#!/usr/bin/env bash
set -eu

cd $(dirname $0)

provision/setup.sh
provision/run.sh $@
provision/cleanup.sh
