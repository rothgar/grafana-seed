#!/bin/sh
#set -x

DATASOURCE_DIR=${DATASOURCE_DIR:-/srv/grafana/datasources}
DASHBOARD_DIR=${DASHBOARD_DIR:-/srv/grafana/dashboards}
GRAFANA_URL=${GRAFANA_URL:-grafana:3000}

command -v curl >/dev/null 2>&1 || apk add --update curl

deploy_datasources() {
  for ds in $(ls -A $DATASOURCE_DIR); do
    echo "Deploying ${ds}"
    curl -X POST -d @"${DATASOURCE_DIR}/${ds}" \
      --header "Content-Type: application/json" \
      --url "${GRAFANA_URL%/}/api/datasources"
    printf "\n\n"
  done
}

deploy_dashboards() {
  for db in $(ls -A $DASHBOARD_DIR); do
    echo "Deploying ${db}"
    curl -X POST -d @"${DASHBOARD_DIR}/${db}" \
      --header "Content-Type: application/json" \
      --url "${GRAFANA_URL%/}/api/dashboards/db"
    printf "\n\n"
  done
}

# blocking loop waiting for grafana
echo "Waiting for grafana URL"
until $(curl --output /dev/null --silent --head --url "${GRAFANA_URL%/}"); do
  printf '.'
  sleep 5
done

echo "URL Ready"
echo "==========================="
echo "Deploying datasources"
echo "---------------------------"
deploy_datasources
echo "==========================="
echo "Deploying dashboards"
echo "---------------------------"
deploy_dashboards
echo "==========================="
echo "Done"
