'use strict'

CollectionView = require('views/base/collection')
NewsView = require('./item')
PagerView = require "views/news/pager"

module.exports = class NewsListView extends CollectionView
  className: 'news-view'
  container: '#content-container'
  listSelector: "#news-list-container"
  containerMethod: "html"
  template: require('./template')
  # tagName: 'li'
  listSelector: 'ol'

  initialize: ->
    console.log "NewsView#initialize ... #{@collection}"
    super
    pagerView = new PagerView model: @collection.pager, autoRender: false
    @subview "pagerView", pagerView


  listen: 
    "change collection" : "render"

  initItemView: (item) =>
    console.log "NewsListView#initItemView ... #{item.get('title')}"
    new NewsView model: item

  # getView: (item) ->
  #   # Instantiate an item view
  #   new NewsView model: item

  render: ->
    super
    @subview("pagerView").render()