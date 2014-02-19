'use strict'

Model = require('models/base/model')

module.exports = class Book extends Model
  url: ->
    "http://ds-wokwin.rhcloud.com/stkdata/q/#{@get('code')}"
  # code: "book-cid"

  parse: (response) ->
    if response.status is "ok"
      [cname, ename, industry] = response.result[0].split(";")
      [bid, ask] = response.result[1].split(";")
      [date, time, open, high, low, close, volume] = response.result[2].split(";")
      @set 
        name: cname
        ename: ename
        industry: industry
        quote: 
          date: date
          time: time
          bid: bid
          ask: ask
          open: open
          high: high
          low: low
          close: close
          volume: volume
      # @set("bidAsk", response.result[1])
      # @set("quote", response.result[2])

    console.log ("Book#parse #{@get('name')}")