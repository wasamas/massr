#!/usr/bin/env bash
npm run production
bundle exec puma -p $PORT
