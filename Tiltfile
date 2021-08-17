def trigger_on_build_state(resource_name, cmd):
  script_path = os.path.join(os.path.dirname(__file__), 'watch.sh')
  watch_file(script_path)
  if type(cmd) == 'string':
    cmd = [script_path, 'bash -c %s' % (shlex.quote(cmd))]
  elif type(cmd) == 'list':
    cmd = [script_path] + cmd
  local_resource(resource_name, serve_cmd=cmd, deps=[script_path])
