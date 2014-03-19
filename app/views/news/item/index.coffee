'use strict'

View = require('views/base/view')

module.exports = class NewsView extends View
  className: 'news-view'
  container: '#news-list'
  template: require('./template')

  initialize: ->
    console.debug "NewsView#initialize ...", @model

  listen: 
    "change model" : "render"
