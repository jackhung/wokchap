'use strict'

Controller = require('controllers/base/controller')
utils = require 'lib/utils'

News = require 'models/news'
NewsList = require 'models/news_list'
Pager = require 'models/pager'

NewsView = require('views/news/item')
NewsListView = require 'views/news/list'
# PagerView = require 'views/news/pager'

SiteView = require "views/site-view"

module.exports = class NewsController extends Controller

  initialize: ->
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
    @model = new News(link: params.link)
    @view = new BooksView( model: @model, autoRender: false, containerMethod: "html" )

    # rivets.bind(@view.$el,{book: @model})
    @model.fetch().then =>
      # @view.render()
      console.log "book#show done:", @model.attributes
      setInterval =>
          @model.fetch()  #self.emit 'tick'
        , 5000