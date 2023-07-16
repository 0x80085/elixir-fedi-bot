#!/bin/bash

echo Starting migrations

exec env MIX_ENV=prod env SECRET_KEY_BASE="??" env DATABASE_URL="ecto://user:pass@localhost/bot" mix ecto.migrate 
