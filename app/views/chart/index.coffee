'use strict'

View = require('views/base/view')
SimpleGraph = require "views/chart/simple-graph"
VolumeGraph = require "views/chart/volume-graph"
# SimpleGraphOrig = require "views/chart/js-simple-graph"
PriceData = require "views/chart/stock-price-service"

module.exports = class ChartView extends View
  className: 'chart-view'
  container: '#content-container'
  template: require('./template')

  defaults: 
    height: 200;

  initialize: ->
    super
    console.log "ChartView#initialize ... #{@model.get('code')}"

  createGraphs: =>
    console.debug "ChartView#createCandleGraph: ", $('#candle-graph')
    @priceData = new PriceData 
      stkCode: @model.get('code')

    @candleGraph = new SimpleGraph
      el: '#candle-graph' 
      model: @priceData

    @volumeGraph = new VolumeGraph
      el: '#volume-graph'
      model: @priceData
      xaxis: false
      zoomable: false

    @priceData.doFetch().then =>
      console.log ".............. fetched"
      @dataLength = @priceData.get("priceData").length

      @listenTo @priceData, "change", =>
        @candleGraph.resetZoom()
        @volumeGraph.resetZoom()

      @listenTo @priceData, "change:signalHist", -> console.log "signal history ready ............" 
      # @listenTo @priceData, "change:dailySignals", -> console.log "daily signal ready ............" 
    @subscribeEvent 'zoomed', @zoomed

  listen: 
    "change model" : "updateChart"    # realtime quote
    # "sync model" : "updateChart"

  updateChart: ->
    quote = @model.attributes
    @priceData.addOrUpdateQuote quote
    now = moment().format("hh:mm")
    f = d3.formatPrefix(quote.volume)
    vol = "#{f.scale(quote.volume)}#{f.symbol}"
    $("#page-head-cotainer").html "#{quote.close} #{quote.ask} #{quote.bid}<br> #{vol} #{now}"


  zoomed: (domain) ->
    @dataLength = @priceData.get("priceData").length
    if domain[1] > @dataLength
      domain[1] = @dataLength
    @candleGraph.zoomHandler domain
    @volumeGraph.zoomHandler domain

  render: ->
    super
    console.debug @model.attributes, @candleGraph
    _.defer @createGraphs unless @candleGraph

  dispose: ->
    console.log "ChartView#dispose"
    super




