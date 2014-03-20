config = {api: {}}

local = true

config.api.root = if local
  'http://dev.wokwin.com:9080'
else
  'http://test01-wokwin.rhcloud.com'

config.api.versionRoot = config.api.root + '/v1'

module.exports = config
