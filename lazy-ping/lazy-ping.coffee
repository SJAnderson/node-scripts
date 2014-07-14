sys = require('sys')
exec = require('child_process').exec
log = (arg) -> console.log arg
warn = (arg) ->
  console.log arg
  process.kill()

usage = '''
  LAZY PING
  By Steve Anderson

  hostname <host>         set ping hostname target
  limit <limit>           set ping test limit
  '''

settings = {
  ping_limit: undefined
  host: undefined
}

cache = {
  wait_over: false
  ping_count: 0
  dot_flip: false
}

# update settings with arguments
args = process.argv.slice 2
for v, i in args
  switch v
    when 'hostname'
      settings.host = args[i+1]
    when 'limit'
      settings.ping_limit = args[i+1]

# print usage if no arguments given
warn usage if not settings.host

# inital text
init_test = """
  Node Ping Test
  Hostname: #{settings.host}
  Ping Limit: #{settings.ping_limit or 'none'}

  """

# test status string
test_status = (count, host, limit) ->
  """\n\n
  ===================================
  TEST [#{count}]
  Host: #{host}
  Ping limit: #{limit or 'none'}
  ===================================

  Results...
  """

# outputs
puts = (error, stdout, stderr) ->
  # turn off waiting message
  cache.wait_over = true

  # kill if illegal ping operation
  warn sys.puts stderr if stderr.match /illegal option/g

  # update ping count
  cache.ping_count++

  # pring test results
  log test_status cache.ping_count, settings.host, settings.ping_limit

  # failed ping
  if stderr
    cache.wait_over = false
    sys.puts stderr
    warn 'Ping limit reached' if settings.ping_limit is cache.ping_count
    setTimeout ( ->
      exec "ping -c 3 #{settings.host}", puts
    ), 5000

  # successful ping
  warn sys.puts stdout if stdout

loadString = =>
  return clearInterval loadString if cache.wait_over
  cache.dot_flip = not cache.dot_flip
  dots = '.' if cache.dot_flip
  log 'Waiting' + (dots or '..')

exec_fn = ->
  log init_test
  setInterval loadString, 1500
  exec "ping -c 3 #{settings.host}", puts

exec_fn()
