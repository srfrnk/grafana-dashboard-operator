function(imagePrefix, buildNumber) (
  local kube = import './kube.libsonnet';
  kube.ConfigMap(name='grafana-dashboard-operator', namespace='grafana-dashboard-operator', data={
    'grafana-host': 'http://kube-prometheus-stack-grafana.monitoring',
  })
)
