function(imagePrefix, buildNumber) (
  local metacontroller = import './metacontroller.libsonnet';
  metacontroller.CompositeController(
    namespace='grafana-dashboard-operator',
    name='grafana-dashboard-operator',
    parentResource={
      apiVersion: 'grafana.operators/v1',
      resource: 'grafana-dashboards',
    },
    syncHook={
      webhook: {
        url: 'http://grafana-dashboard-operator.grafana-dashboard-operator/sync',
        timeout: '200s',
      },
    },
    finalize={
      webhook: {
        url: 'http://grafana-dashboard-operator.grafana-dashboard-operator/finalize',
        timeout: '200s',
      },
    }
  )
)
