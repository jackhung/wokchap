'use strict'

View = require('views/base/view')
SimpleGraph = require "views/chart/simple-graph"
VolumeGraph = require "views/chart/volume-graph"
PriceData = require "views/chart/stock-price-service"
QuoteView = require 'views/chart/quote-view'

module.exports = class ChartView extends View
  className: 'chart-view'
  container: '#content-container'
  # autoRender: false
  template: require('./template')

  defaults: 
    height: 200;

  regions:
    rtquotePanel: "#page-head-cotainer-l1"

  initialize: ->
    super
    console.log "ChartView#initialize ... #{@model.get('code')}"
    @priceData = new PriceData 
      stkCode: @model.get('code')

    @priceData.doFetch().then =>
      @createGraphs() unless @subview "candleGraph"

  createGraphs: =>
    candleGraph = new SimpleGraph
      el: '#candle-graph' 
      model: @priceData
    @subview "candleGraph", candleGraph

    volumeGraph = new VolumeGraph
      el: '#volume-graph'
      model: @priceData
      xaxis: false
      zoomable: false
    @subview "volumeGraph", volumeGraph

    quoteView = new QuoteView
      model: @model
    @subview "quoteView", quoteView

    v.onPriceDataReady?() for v in @subviews
    v.resetZoom?() for v in @subviews

    @listenTo @priceData, "change", =>  # do this for now, don't know why the listen in subview not working!
      v.onPriceDataChanged?() for v in @subviews
    @subscribeEvent 'zoomed', @zoomed

  listen: 
    "change model" : "quoteChanged"    # realtime quote

  quoteChanged: ->
    quote = @model.attributes
    @priceData.addOrUpdateQuote quote
    # see QuoteView
    # now = moment().format("hh:mm")
    # f = d3.formatPrefix(quote.volume)
    # vol = "#{f.scale(quote.volume)}#{f.symbol}"
    # $("#page-head-cotainer").html "#{quote.close} #{quote.ask} #{quote.bid}<br> #{vol} #{now}"

  zoomed: (domain) ->
    @dataLength = @priceData.get("priceData").length
    if domain[1] > @dataLength
      domain[1] = @dataLength
    v.zoomHandler? domain for v in @subviews

  dispose: ->
    console.log "ChartView#dispose"
    # @priceData = null
    # @priceData.dispose() if @priceData
    super




