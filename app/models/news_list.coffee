'use strict'

Collection = require('models/base/collection')
News = require('./news')

module.exports = class NewsList extends Collection
  model: News
  url: ->
    "http://dev.wokwin.com:9080/finNews?#{@pagerParams()}"

  parse: (response) ->
    # console.log "========= #{@pager}"
    @pager.set response.pageMeta
    console.log "NewsList parse status: #{response.status}, offset: #{@pager.get('offset')}"
    return response.result;

  pagerParams: () ->
    "offset=#{@pager.get('offset')}&max=#{@pager.get('max')}"