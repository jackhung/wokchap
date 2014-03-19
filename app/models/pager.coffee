'use strict'

Model = require('models/base/model')

module.exports = class Pager extends Model
  defaults:
    offset: 0
    max: 20
    totalPages: -1

  initialize: (attributes, options) ->
    super
    console.debug 'Pager#initialize', @, attributes, options

  # test if we have data from the server, see PagerView#render
  isReady: () ->
    @totalPages != -1

