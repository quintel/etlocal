#!/bin/bash

set -e

# Decrypt energy balances if ETSOURCE_KEY is set.
if [[ -z "${ETSOURCE_KEY}" && ( "${RAILS_ENV}" == "production" || "${RAILS_ENV}" == "staging" )]]; then
  bundle exec rake deploy:load_etsource
fi

# Start Rails.
bundle exec --keep-file-descriptors puma -C config/puma.rb
