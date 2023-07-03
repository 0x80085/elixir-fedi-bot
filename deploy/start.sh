#!/bin/bash

echo Starting server

exec env PORT=4001 env PHX_HOST=?? env MIX_ENV=prod env SECRET_KEY_BASE="???" env DATABASE_URL="ecto://USER:PASS@localhost/bot" mix phx.server 

echo Done.
