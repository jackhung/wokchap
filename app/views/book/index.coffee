'use strict'

View = require('views/base/view')

module.exports = class BookView extends View
  className: 'book-view'
  container: '#content-container'
  template: require('./template')

  initialize: ->
    console.log "BookView#initialize ... #{@model.code}"

  listen: 
    "change model" : "render"
