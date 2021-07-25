#!/bin/bash

CHART_PATH="$(dirname $0)/../chart"

helm upgrade wargames $CHART_PATH \
  --namespace wargames \
  --set wargames.secretKeyBase=$SECRET_KEY_BASE \
  --set wargames.host=$HOST \
  --force
