'use strict'

Model = require('models/base/model')

module.exports = class Book extends Model
  url: ->
    "http://test01-wokwin.rhcloud.com/quote/q/#{@get('code')}"
  # code: "book-cid"

  parse: (data) ->
    console.log ("Book#parse #{data.result.cName}")
    data.result