'use strict'

View = require('views/base/view')

module.exports = class NewsView extends View
  className: 'news-view'
  container: '#news-list'
  template: require('./template')

  initialize: ->
    console.log "NewsView#initialize ... #{@model.get('title')}"

  listen: 
    "change model" : "render"
