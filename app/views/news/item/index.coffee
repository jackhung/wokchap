'use strict'

View = require('views/base/view')
ViewHelper = require "lib/view-helper"

module.exports = class NewsView extends View
  _.extend @prototype, ViewHelper

  className: 'news-view'
  container: '#news-list'
  template: require('./template')
  autoRender: false

  initialize: ->
    # console.debug "NewsView#initialize ...", @model
    super

  # listen: 
  #   "change model" : "render"
    # "mouseover .stock-tip" : 'showTip'

  _tip_popover_initialized: 0

  render: ->
    super
    console.log "News item view: render #{@model.get('title')}, Tip popover initialized: #{@_tip_popover_initialized}"
    return if @_tip_popover_initialized isnt 0
    @initTip()
    @_tip_popover_initialized++

