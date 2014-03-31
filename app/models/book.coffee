'use strict'

Model = require('models/base/model')
config = require "config"

module.exports = class Book extends Model
  url: ->
    "#{config.api.root}/quote/q/#{@get('code')}"
  # code: "book-cid"

  parse: (data) ->
    # console.log ("Book#parse #{data.result.cName}")
    data.result