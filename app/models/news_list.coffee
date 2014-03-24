'use strict'

Collection = require('models/base/collection')
News = require('./news')
config = require "config"

module.exports = class NewsList extends Collection
  model: News
  url: ->
    "#{config.api.root}/finNews?#{@pagerParams()}"

  parse: (response) ->
    # console.log "========= #{@pager}"
    @pager.set response.pageMeta
    console.log "NewsList parse status: #{response.status}, offset: #{@pager.get('offset')}"
    return response.result;

  pagerParams: () ->
    "offset=#{@pager.get('offset')}&max=#{@pager.get('max')}"