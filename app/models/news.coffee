'use strict'

Model = require('models/base/model')
config = require "config"

module.exports = class News extends Model
  # idAttribute: "link"
  url: ->
    "#{config.api.root}/finNews/#{@id}"

  parse: (data) =>
    # console.log data.title
    data
    # super.parse data
    # if response.status is "ok"
    #   data = response.result
    #   @set 
    #     title: data.title
    #     date: data.date
    #     author: data.author
    #     source: data.source
    #     link: data.link
    #     codes: data.codes

    # console.log ("News#parse #{@get('title')}")
