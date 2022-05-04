#!/bin/bash

while true; do
  inotifywait -e modify,create,delete -r "$KEYFILES_DIR" && /usr/bin/reload-keys.sh
done