'use strict'

View = require('views/base/view')

module.exports = class NewsShowView extends View
  className: 'news-view'
  container: '#content-container'
  template: require('./show')

  initialize: ->
    # console.debug "NewsView#initialize ...", @model
    super

  listen: 
    "change model" : "render"
    "mouseover .stock-tip" : 'showTip'

  showTip: (e) ->
    console.debug $(e.target).attr("ref")

  render: ->
    super
    @delegate "mouseover", ".stock-tip", @showTip

