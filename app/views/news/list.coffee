'use strict'

CollectionView = require('views/base/collection')
NewsView = require('./item')
PagerView = require "views/news/pager"

module.exports = class NewsListView extends CollectionView
  className: 'news-view'
  container: '#page-container'
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

  initItemView: (model) =>
    console.log "NewsListView#initItemView ... #{model.get('title')}"
    new NewsView model: model

  render: ->
    super
    @subview("pagerView").render()