'use strict'

View = require('views/base/view')

module.exports = class NewsView extends View
  className: 'news-view'
  container: '#news-list'
  template: require('./template')

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
