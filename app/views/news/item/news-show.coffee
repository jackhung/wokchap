'use strict'

View = require('views/base/view')
ViewHelper = require "lib/view-helper"
utils = Chaplin.utils

module.exports = class NewsShowView extends View
  _.extend @prototype, ViewHelper

  className: 'news-view'
  container: '#content-container'
  template: require('./show')

  listen: 
    "change model" : "render"
    "mouseover .stock-tip" : 'showTip'

  events:
    "click .stock-ref" : "openChart"

  render: ->
    super
    # @$el.find(".stock-ref").each (ref) ->
    #   $this = $(@)
    #   code = $this.attr("ref")
    #   $(" <i class='cus-chart-line stock-tip' ref='#{code}'></i> ").insertAfter($this)

    # @initTip()  # see ViewHelper
    @initStockRef @$el.find(".stock-ref")

  openChart: (e) ->
    $this = $(e.target)
    code = $this.attr("ref")
    utils.redirectTo 'chart#show', {code: code}
