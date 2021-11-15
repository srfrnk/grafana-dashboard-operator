function(imagePrefix, buildNumber) (
  local kube = import './kube.libsonnet';
  kube.Service(
    namespace='grafana-dashboard-operator',
    name='grafana-dashboard-operator',
    selector={ app: 'grafana-dashboard-operator' },
    ports=[{
      protocol: 'TCP',
      targetPort: 80,
      port: 80,
      name: 'web',
    }]
  )
)
