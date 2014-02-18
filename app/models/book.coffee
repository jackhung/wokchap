'use strict'

Model = require('models/base/model')

module.exports = class Book extends Model
  url: "http://ds-wokwin.rhcloud.com/stkdata/q/00175"
  # code: "book-cid"

  parse: (response) ->
    if response.status is "ok"
      @set("name", response.result[0])
      @set("bidAsk", response.result[1])
      @set("quote", response.result[2])

    console.log ("Book#parse #{@get('name')}")