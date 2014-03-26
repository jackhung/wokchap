'use strict'

Controller = require('controllers/base/controller')
utils = require 'lib/utils'

News = require 'models/news'
NewsList = require 'models/news_list'
Pager = require 'models/pager'

NewsShowView = require('views/news/item/news-show')
NewsListView = require 'views/news/list'
# PagerView = require 'views/news/pager'

SiteView = require "views/site-view"

module.exports = class NewsController extends Controller

  initialize: ->
    super
    @reuse 'site', SiteView
    console.log "NewsController#initialize ... reuse site"
    @pager = new Pager()

  list: (params, route) ->
    @collection = new NewsList()
    @collection.pager = @pager
    # @pageView = new PagerView(model: @pager)
    query = utils.queryParams.parse(route.query)
    @pager.set("offset", query.offset) if query.offset
    @pager.set("max", query.max) if query.max

    @view = new NewsListView( collection: @collection)
    @collection.fetch().then =>
      console.log "news list fetched"
      # @view.render()

  show: (params, route) ->
    console.debug "news#show", params
    @model = new News(id: params.id)
    @view = new NewsShowView( model: @model, autoRender: false, containerMethod: "html" )

    # rivets.bind(@view.$el,{book: @model})
    @model.fetch().then =>
      # @view.render()
      console.log "news#show done:", @model.attributes
