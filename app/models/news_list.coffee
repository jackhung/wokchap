'use strict'

Collection = require('models/base/collection')
News = require('./news')

module.exports = class NewsList extends Collection
  model: News
  url: ->
    "http://dev.wokwin.com:9080/finNews"

  parse: (response) ->
    @pageInfo = response.pageMeta
    console.log "NewsList parse status: #{response.status}, offset: #{@pageInfo.offset}"
    return response.result;
