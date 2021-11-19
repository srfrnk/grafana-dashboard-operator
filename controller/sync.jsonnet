function(request, now, uids, hashes)
  {
    local parent = { status: { uids: [] } } + request.parent,
    status: {
      uids: [x for x in std.uniq(std.sort(parent.status.uids + uids)) if x != ''],
      lastDeploy: hashes,
    },
    children: [],
    resyncAfterSeconds: 10.0,
  }
