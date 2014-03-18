'use strict'

CollectionView = require('views/base/collection')
NewsView = require('./item')

module.exports = class NewsListView extends CollectionView
  className: 'news-view'
  container: '#page-container'
  template: require('./template')
  tagName: 'li'
  listSelector: 'ol'

  initialize: ->
    console.log "NewsView#initialize ... #{@collection}"

  listen: 
    "change collection" : "render"

  initItemView: (model) =>
    console.log "NewsListView#initItemView ... #{model.get('title')}"
    new NewsView model: model
