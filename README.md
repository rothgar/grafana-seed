Grafana seed
-----------

Seeds grafana with datasources and dashboards using the API.

Can be used with any grafana instance without auth. grafana-seed pod provided to deploy to Kubernetes.

## Requirements

- Grafana should be running and accessible on the network. If deploying to kubernetes make sure you have a grafana service created for in cluster discovery.
- Grafana should be set up to not need authentication (at least initially)
- Exported dashboard .json files to deploy

## Create datasources and dashboards

To create a datasource you can manually create one and then pull out the json data using the [grafana api](http://docs.grafana.org/reference/http_api/), or you can also look at the demo prometheus datasource provided and modify it for your needs. **Huge thanks to [Robust Perception](http://www.robustperception.io/) for hosting a publically available prometheus server for sample data**

To create a dashboard you can create it manually via the gui or import one from [grafana.net](http://grafana.net) and then click the gear icon and view the json. Save the json to a file and open it in your editor. You need to make 3 small changes.

1. Create a top level key called dashboard
2. Change the id: value to null
3. Create an overwrite: true key at the same level as dashboard

The file should look similar to this (data snipped for simplicity)

```
{
  "dashboard": {
    "id": null,
    "title": "Production Overview",
    "tags": [ "templated" ],
    "timezone": "browser",
    "rows": [
      {
      }
    ],
    "schemaVersion": 6,
    "version": 0
  },
  "overwrite": true
}
```

Once you have your datasources and dashboards folders it's best to store these in git so you can iterate over them and deploy them again later.

If you need more ideas for dashboards you can check out [play.grafana.org](http://play.grafana.org/) and [grafana.wikimedia.org](https://grafana.wikimedia.org/)

## Variables

Default values for the variables are

```
DATASOURCE_DIR = /srv/grafana-seed/datasources
DASHBOARD_DIR  = /srv/grafana-seed/dashboards
GRAFANA_URL    = http://grafana:3000
```

You can override these variables in your local shell with

```
export DATASOURCE_DIR='/foo/bar/datasources'
export DASHBORD_DIR='/foo/bar/dashboards'
export GRAFANA_URL='http://graphs:3000'
```

If you're using the seed pod in kubernetes you can uncomment the lines in that yaml file and create a config map with the following information.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-seed-config
  namespace: default
data:
  datasources-dir: /foo/bar/datasources
  dashboard-dir: /foo/bar/dashboards
  prom-url: http://grafana:90000
```

## Running

If you're running locally in your shell you can use `./seed.sh`.

If you want to deploy a pod to seed a grafana instance running in Kubernetes then use the example grafana-seed.pod.yaml. Make sure you change the repository url to one that stores your datasources and dashboards.

```
kubectl create -f grafana-seed.pod.yaml
```

## Debug

Uncomment the `set -x` line to see what the script is running. If you deployed a pod then you can use

```
kubectl logs -p grafana-seed
```

The pod is set to not restart. You could with minor changes make the pod continually push config to grafana and keep the pod always running but that is not the goal of this "seed" script.
