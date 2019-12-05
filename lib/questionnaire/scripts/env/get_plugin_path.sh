#!/usr/bin/env bash

set -e
srcipt_path=$(dirname $(realpath $0))
cd $(realpath $srcipt_path/../../../..)
bin/rails r "puts Gem.loaded_specs['oq_web_plugin'].full_gem_path"
