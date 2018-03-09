#!/bin/bash

[[ $START_SCRIPT == http* ]] && curl -s $START_SCRIPT > /start_script && START_SCRIPT="/start_script" && chmod +x $START_SCRIPT

if [ -n "$START_SCRIPT" ]; then
  $START_SCRIPT
else
  echo "You need to pass in a START_SCRIPT as a path or url"
  exit 1
fi