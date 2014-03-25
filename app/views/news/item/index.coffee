'use strict'

View = require('views/base/view')
ViewHelper = require "lib/view-helper"

module.exports = class NewsView extends View
  _.extend @prototype, ViewHelper

  className: 'news-view'
  container: '#news-list'
  template: require('./template')

  initialize: ->
    # console.debug "NewsView#initialize ...", @model
    super

  listen: 
    "change model" : "render"
    # "mouseover .stock-tip" : 'showTip'

  render: ->
    super
    @initTip()


