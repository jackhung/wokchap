'use strict'

View = require('views/base/view')
ViewHelper = require "lib/view-helper"

module.exports = class NewsShowView extends View
  _.extend @prototype, ViewHelper

  className: 'news-view'
  container: '#content-container'
  template: require('./show')

  initialize: ->
    # console.debug "NewsView#initialize ...", @model
    super

  listen: 
    "change model" : "render"
    "mouseover .stock-tip" : 'showTip'

  render: ->
    super
    @$el.find(".stock-ref").each (ref) ->
      $this = $(@)
      code = $this.attr("ref")
      $(" <span class='glyphicon glyphicon-eye-open stock-tip' ref='#{code}'></span> ").insertAfter($this)
      console.debug $this.attr("ref")
    @initTip()
