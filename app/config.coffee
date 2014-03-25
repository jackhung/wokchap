config = {api: {}}

cloudhosts = ["rhcloud.com"]
host = window.location.hostname

cloudDeploy = _.find(cloudhosts, (n) -> host.indexOf(n) > 0 )

console.log "Cloud Deployed? #{cloudDeploy}"

config.api.root = if cloudDeploy
  "http://#{host}"
else
  'http://dev.wokwin.com:9080'

config.contextRoot = "/app"

config.api.versionRoot = config.api.root + '/v1'

module.exports = config
