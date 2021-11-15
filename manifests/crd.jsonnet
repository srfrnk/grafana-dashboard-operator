function(imagePrefix, buildNumber) (
  local kube = import './kube.libsonnet';
  kube.CRD(kind='GrafanaDashboard',
           singular='grafana-dashboard',
           plural='grafana-dashboards',
           group='grafana.operators',
           versions=[
             {
               name: 'v1',
               served: true,
               storage: true,
               subresources: {
                 status: {},
               },
               schema: {
                 openAPIV3Schema: {
                   type: 'object',
                   required: ['spec'],
                   description: 'A Grafana Dashboard definition.',
                   properties: {
                     status: {
                       type: 'object',
                       properties: {
                         uids: {
                           type: 'array',
                           items: {
                             type: 'string',
                           },
                         },
                       },
                     },
                     spec: {
                       type: 'object',
                       description: 'A Grafana Dashboard definition. **Must contain exactly one of [`dashboard`, `dashboards`, `grafonnet`]**',
                       properties: {
                         dashboard: {
                           type: 'object',
                           'x-kubernetes-preserve-unknown-fields': true,
                           description: 'A grafana dashboard model (`JSON`)',
                         },
                         dashboards: {
                           type: 'array',
                           description: 'List of grafana dashboard models (`JSON`)',
                           items: {
                             type: 'object',
                             'x-kubernetes-preserve-unknown-fields': true,
                             description: 'A grafana dashboard model (`JSON`)',
                           },
                         },
                         grafonnet: {
                           type: 'object',
                           description: 'List of grafonnet files',
                           additionalProperties: {
                             type: 'string',
                             description: 'List of grafonnet files (jsonnet / libsonnet)',
                           },
                         },
                       },
                       oneOf: [
                         {
                           required: [
                             'dashboard',
                           ],
                         },
                         {
                           required: [
                             'dashboards',
                           ],
                         },
                         {
                           required: [
                             'grafonnet',
                           ],
                         },
                       ],
                     },
                   },
                 },
               },
             },
           ])
)
