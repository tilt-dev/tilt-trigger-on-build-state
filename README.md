Allows you to specify a command that will be run whenever a resource's update state changes.

The command will have these environment variables set:
- `RESOURCE_NAME` - the name of the resource whose state has changed
- `TIMESTAMP` - time at which the state changed
- `EVENT` - "start" or "finish", indicating whether the build just started or just finished
- `DURATION` - The number of milliseconds the build took (only if `$EVENT` is "finish"
- `RESULT` - "success" or "failure" (only if `$EVENT` is "finish")

Examples:
```
# honk when a build fails
trigger_on_build_state('honk', 'if [[ $RESULT == failure ]]; then play honk.wav; fi')

# run integration tests when a server comes up
# (assuming the server is named "myserver" and you have a tilt resource named "myserver_integration_tests" that runs your tests)
trigger_on_build_state('integration_trigger', 'if [[ $RESOURCE_NAME == myserver && $RESULT == success ]]; then tilt trigger myserver_integration_tests; fi')

# report builds to graphite, to monitor your teams' build times
# (assumes you have graphite/statsd running at graphite.example.com:8125)
trigger_on_build_state('graphite_reporter', if [[ $EVENT == finish ]]; then echo "builds.$RESOURCE_NAME:$DURATION|ms" | nc -w 1 -cu graphite.example.com 8125; fi"
```
