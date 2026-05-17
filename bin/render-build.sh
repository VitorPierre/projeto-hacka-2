#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails assets:precompile