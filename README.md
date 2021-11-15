# grafana-dashboard-operator

A Kubernetes operator to deploy Grafana dashboards

## TL;DR

Jump to [Usage](#usage)

## Prerequisites

A K8s CRD operator to maintain [Grafana](https://github.com/grafana/) [dashboards](https://grafana.com/docs/grafana/latest/dashboards/?pg=graf-resources&plcmt=create-a-dashboard).
Every Grafana Dashboard is represented by Grafana API using a [JSON model](https://grafana.com/docs/grafana/latest/dashboards/json-model/).
E.g.:

```json
{
  "id": null,
  "uid": "cLV5GDCkz",
  "title": "New dashboard",
  "tags": [],
  "style": "dark",
  "timezone": "browser",
  "editable": true,
  "hideControls": false,
  "graphTooltip": 1,
  "panels": [],
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {
    "time_options": [],
    "refresh_intervals": []
  },
  "templating": {
    "list": []
  },
  "annotations": {
    "list": []
  },
  "refresh": "5s",
  "schemaVersion": 17,
  "version": 0,
  "links": []
}
```

[K8s](https://kubernetes.io/) is a container orchestration framework.
The K8s API uses [Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/) to define resources to orchestrate.
K8s controls the lifecycle of objects for you.
E.g.:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.14.2
          ports:
            - containerPort: 80
```

K8s also allows extending the API by defining your own custom objects. These are called [CRD](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)s.
After defining a CRD it needs to be controlled by a [controller](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#custom-controllers).
As it might not be so simple to build a controller with the K8s API a few frameworks have been published to help with this task.
One framework for building K8s custom controllers is [Metacontroller](https://github.com/metacontroller/metacontroller).

This project uses Metacontroller to create a custom controller.

[Grafonnet](https://github.com/grafana/grafonnet-lib) is a [Jsonnet](https://jsonnet.org/) based library to generate Grafana Dashboards from code/template.

## Goal

To add a CRD that allows defining Grafana Dashboard.
Maintain Grafana Dashboards using the Grafana API by a custom controller.
The CRD should allow using a Grafana JSON Model as well as Grafonnet code.

## Usage

1. Connect kubectl to your cluster.
2. Make sure `Grafana` is deployed i.e. by installing `kube-prometheus-stack` from `https://prometheus-community.github.io/helm-charts` in namespace `monitoring`. **[Optional]**
3. Make sure `Metacontroller` is deployed i.e. by running `kubectl apply -n metacontroller -k https://github.com/metacontroller/metacontroller/manifests/production`
4. Install `grafana-dashboard-operator` by running `kubectl apply -n grafana-dashboard-operator -f https://github.com/srfrnk/grafana-dashboard-operator/releases/latest/download/grafana-dashboard-operator-manifests.yaml`
5. Update the `ConfigMap` named `grafana-dashboard-operator` (in namespace `grafana-dashboard-operator`) `grafana-host` property to point to your `Grafana` instance. **Not required if step 2 has been followed**
6. Update the `Secret` named `grafana-api` (in namespace `grafana-dashboard-operator`) `token` property to a valid [Grafana API Key Token](https://grafana.com/docs/grafana/latest/http_api/auth/) with appropriate permissions (E.g. `Admin` role)
7. See [API docs](https://srfrnk.github.io/grafana-dashboard-operator/)
8. Deploy `GrafanaDashboard` objects for your dashboards See example below.

## GrafanaDashboard Example

### Single JSON Model

```yaml
apiVersion: grafana.operators/v1
kind: GrafanaDashboard
metadata:
  name: dashboard-example
  namespace: default
spec:
  dashboard:
    {
      dashboard:
        {
          "annotations": { "list": [] },
          "editable": true,
          "gnetId": null,
          "graphTooltip": 0,
          "links": [],
          "panels": [],
          "schemaVersion": 30,
          "style": "dark",
          "tags": [],
          "templating": { "list": [] },
          "time": { "from": "now-6h", "to": "now" },
          "timepicker": {},
          "timezone": "",
          "title": "dashboard 3",
          "version": 1,
        },
      "folder": "test folder",
      "overwrite": true,
    }
```

### Multiple JSON Models

```yaml
apiVersion: grafana.operators/v1
kind: GrafanaDashboard
metadata:
  name: dashboards-example
  namespace: default
spec:
  dashboards:
    [
      {
        dashboard:
          {
            "annotations": { "list": [] },
            "editable": true,
            "gnetId": null,
            "graphTooltip": 0,
            "links": [],
            "panels": [],
            "schemaVersion": 30,
            "style": "dark",
            "tags": [],
            "templating": { "list": [] },
            "time": { "from": "now-6h", "to": "now" },
            "timepicker": {},
            "timezone": "",
            "title": "dashboard 1",
            "version": 1,
          },
        "folder": "test folder",
        "overwrite": true,
      },
      {
        dashboard:
          {
            "annotations": { "list": [] },
            "editable": true,
            "gnetId": null,
            "graphTooltip": 0,
            "links": [],
            "panels": [],
            "schemaVersion": 30,
            "style": "dark",
            "tags": [],
            "templating": { "list": [] },
            "time": { "from": "now-6h", "to": "now" },
            "timepicker": {},
            "timezone": "",
            "title": "dashboard 2",
            "version": 1,
          },
        "folder": "test folder",
        "overwrite": true,
      },
    ]
```

### Grafonnet

```yaml
apiVersion: grafana.operators/v1
kind: GrafanaDashboard
metadata:
  name: grafonnet-example
  namespace: default
spec:
  grafonnet:
    "board1.jsonnet": |-
      local grafana = import './vendor/grafonnet/grafana.libsonnet';
      local prometheus = grafana.prometheus;
      local server_dashboard = (import './library1.libsonnet').server_dashboard;
      server_dashboard('stg')

    "library1.libsonnet": |-
      local grafana = import 'vendor/grafonnet/grafana.libsonnet';
      local prometheus = grafana.prometheus;
      local single_app_dashboard = (import './library2.libsonnet').single_app_dashboard;
      {
        server_dashboard(env)::
          single_app_dashboard('server', 'deployment', env)
      }

    "library2.libsonnet": |-
      local grafana = import 'vendor/grafonnet/grafana.libsonnet';
      local dashboard = grafana.dashboard;
      local row = grafana.row;
      local singlestat = grafana.singlestat;
      local prometheus = grafana.prometheus;
      local template = grafana.template;
      {
        single_app_dashboard(app_name, app_type, env)::
          {
            folder: 'test folder',
            overwrite: true,
            dashboard: dashboard.new(
              'dashboard 4',
              schemaVersion=16,
              tags=[app_name, 'Some Label', env],
              graphTooltip=1,
            )
            .addPanel(
              grafana.graphPanel.new(
                'some metric',
              )
              .addTarget(
                prometheus.target(
                  expr='cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits',
                )
              ), gridPos={
                h: 10,
                w: 12,
                x: 0,
                y: 1,
              },
            )
          },
      }
```

## Run Locally (+ Development)

**Attention: You must have [minikube](https://minikube.sigs.k8s.io/) installed**

### Deploy

1. Create a minikube cluster: `minikube start`
2. Run `make local-setup`
3. Run `make local-update`
4. Run `make pf-grafana` then open your browser at http://localhost:3000 to Grafana GUI.

### Tests Examples

```bash
make deploy-examples
```

Or

```bash
kubectl apply -f ./examples/dashboard-test-1.yaml
kubectl apply -f ./examples/dashboard-test-2.yaml
kubectl apply -f ./examples/dashboard-test-3.yaml
```

A new 'test-folder' should be created in Grafana and contain 4 dashboards.
