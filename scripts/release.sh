#!/bin/sh
set -e

mix deps.get
cd assets
yarn install
yarn run deploy
cd ..
mix phx.digest
mix release
