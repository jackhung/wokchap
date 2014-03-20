'use strict'

Model = require('models/base/model')

module.exports = class Woklist extends Model
  # id: 52ddd2f7e4b0fd9f4b50bdb6, 何車

  url: ->
    "http://dev.wokwin.com:8080/wokwin-app/api/wokListItem/52ddd2f7e4b0fd9f4b50bdb6"
    # "http://dev.wokwin.com/:8080/wokwin-app/api/wokListItem/#{id}"

  parse: (data) =>
  	data