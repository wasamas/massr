#!/usr/bin/env bash
[ "$RACK_ENV" == "production" ] && npm run production
bundle exec puma -p $PORT
