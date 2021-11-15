function(request, now, uids)
  {
    local parent = { status: { uids: [] } } + request.parent,
    status: {
      uids:  [x for x in std.uniq(std.sort(parent.status.uids+uids)) if x!=""],
    },
    children: [],
    resyncAfterSeconds: 10.0,
  }
