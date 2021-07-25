#!/bin/bash

CHART_PATH="$(dirname $0)/../chart"

helm install wargames $CHART_PATH \
  --namespace wargames \
  --create-namespace \
  --set wargames.secretKeyBase=$SECRET_KEY_BASE \
  --set wargames.host=$HOST
