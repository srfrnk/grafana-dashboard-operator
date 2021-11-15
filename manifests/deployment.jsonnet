function(imagePrefix, buildNumber) (
  local kube = import './kube.libsonnet';
  kube.Deployment(
    namespace='grafana-dashboard-operator',
    name='grafana-dashboard-operator',
    replicas=1,
    containers=[
      kube.Container(name='controller', image=imagePrefix + 'grafana-dashboard-operator:' + buildNumber) +
      {
        env+: [
          {
            name: 'CGI_ENV_GRAFANA_HOST',
            valueFrom: {
              configMapKeyRef: {
                name: 'grafana-dashboard-operator',
                key: 'grafana-host',
              },
            },
          },
        ],
        volumeMounts+: [
          {
            name: 'grafana-api',
            readOnly: true,
            mountPath: '/grafana_api',
          },
        ],
        ports+: [
          {
            name: 'web',
            protocol: 'TCP',
            containerPort: 80,
          },
        ],
        livenessProbe+: {
          httpGet: {
            path: '/live',
            port: 'web',
          },
        },
        readinessProbe+: {
          httpGet: {
            path: '/live',
            port: 'web',
          },
        },
        resources+: {
          requests+: {
            cpu: '100m',
            memory: '100Mi',
          },
          limits+: {
            cpu: '500m',
            memory: '500Mi',
          },
        },
      },
    ],
    volumes=[{
      name: 'grafana-api',
      secret: {
        secretName: 'grafana-api',
      },
    }]
  )
)
