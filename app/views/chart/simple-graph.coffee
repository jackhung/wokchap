'use strict'

ChartOptions = require 'views/chart/chart-options'
# PriceService = require 'views/chart/stock-price-service'
ChartView = require 'views/chart/base-chart'

module.exports = class SimpleGraph extends ChartView

  initialize: (options) ->
    super

    @downy = Math.NaN;

    dragged: null
    selected: null

  listen:
    "change:signalHist model" : "drawSignals"

  # Real Stock Data ==============================================================
  onPriceDataReady: () =>
    super
    # x-scale
    @x = d3.scale.linear()
        .domain([0, @pData.length])
        .range([0, @size.width]);

    @ymin = d3.min @pData, (d) => d[@PHIGH]
    @ymax = d3.max @pData, (d) => d[@PLOW]
    # y-scale (inverted domain)
    @y = d3.scale.linear()
        .domain([@ymax, @ymin])
        .range([0, @size.height])
        .nice();

    # @initChartElements()
    @renderAxis()

  # ===============================================================================

  plot_drag: () =>
    registerKeyboardHandler(@keydown)
    d3.select('body').style("cursor", "move")

  updateChart: () =>
    @drawCandle()
    @drawSignals()

  drawCircle: ->          
    circle = @vis.select("svg").selectAll(".datapoint")
        .data(@pData)

    dataPoint = circle.enter().append("g")
      .attr("class", "datapoint")
      # .attr("transform", (d, i) => "translate(#{@x(i)},#{@y(d[@PCLOSE])})")

    # circle.enter().append("circle")
    dataPoint.append("circle")
        .attr("class", (d) => if d is @selected then "selected" else null )
        .attr("cx", 0.0 )
        .attr("cy", 0.0 )
        .attr("r", 3.0)
        .style("cursor", "ns-resize")
        # .on("mousedown.drag",  @datapointDrag)
        # .on("touchstart.drag", @datapointDrag)

    circle
      .transition() 
          .duration(300) 
          .attr("transform", (d, i) => "translate(#{@x(i)}, #{@y(d[@PCLOSE])})")

    circle.exit().remove();

    if (d3.event && d3.event.keyCode) 
      d3.event.preventDefault()
      d3.event.stopPropagation()

  drawSignals: () ->
    # dataCnt = @priceData.length
    # size = (@width / dataCnt) * 1.8
    signalData = @model.get "signalHist"
    return unless signalData
    size = Math.abs(@x(1) - @x(0) ) * 1.2
    dx = 0 #size / 2
    buySymbol = d3.svg.symbol().type("triangle-up").size(size)
    sellSymbol = d3.svg.symbol().type("triangle-down").size(size)

    self = @
    signals = @vis.select("svg").selectAll(".signal").data(signalData)

    signals
      .enter().append("path").attr("class", "signal")
      .classed("buy", (d) -> d.hist.buySell is "B")
      .attr("d", (d) -> if d.hist.buySell is "B" then buySymbol(d) else sellSymbol(d))
      .attr("transform", (d) -> "translate(#{self.x(d.x) + dx}, #{self.y(d.hist.price)})")

    signals
      .attr("d", (d) -> if d.hist.buySell is "B" then buySymbol(d) else sellSymbol(d))
      .attr("transform", (d) -> "translate(#{self.x(d.x) + dx}, #{self.y(d.hist.price)})")

    signals.exit().remove()

  allCandles: ->
    @vis.select("svg").selectAll(".candle")

  allStems: ->
    @allCandles().selectAll("line")

  allCandleStems: (topBottom = "top") ->
    @vis.select("svg").selectAll(".candle .stem.#{topBottom}")

  allCandleBodies: ->
    @vis.select("svg").selectAll(".candle .candle-body")

  drawCandle: ->
    unless @tip
      @tip = d3.tip().attr('class', 'd3-tip').html((d) -> "price: " + d[4])
      @vis.call @tip

    candle = @vis.select("svg").selectAll(".candle").data(@pData)

    group = candle.enter().append("g") .attr("class", "candle")
    group.append("svg:line") 
      .attr("class", (d) => if d[@POPEN] > d[@PCLOSE] then "stem top price-down" else "stem top price-up")
    group.append("svg:line") 
      .attr("class", (d) => if d[@POPEN] > d[@PCLOSE] then "stem bottom price-down" else "stem bottom price-up")
    group.append("svg:rect")
      .attr("class", (d) => if d[@POPEN] > d[@PCLOSE] then "candle-body price-down" else "candle-body price-up")
      # .on('mouseover', @tip.show)
      # .on('mouseout', @tip.hide)

    @allCandleStems("top") .attr("x1", 0).attr("y1", (d) => @y d[@PHIGH])
      .attr("x2", 0).attr("y2", (d) => @y(Math.max d[@POPEN], d[@PCLOSE]))
    @allCandleStems("bottom") .attr("x1", 0).attr("y1", (d) => @y d[@PLOW])
      .attr("x2", 0).attr("y2", (d) => @y(Math.min d[@POPEN], d[@PCLOSE]))

    rectWidth = Math.abs(@x(1) - @x(0) ) * 0.6
    # rectHeightRatio = Math.abs(@y(1) - @y(0))
    @allCandleBodies()
      .attr("y", (d) => @y(Math.max( d[@POPEN], d[@PCLOSE] )))
      .attr("height", (d) => Math.abs(@y(d[@PCLOSE]) - @y(d[@POPEN])) or 0.5)
      .attr("x", -rectWidth/2)
      .attr("width", rectWidth)

    candle.exit().remove()

    candle .transition() .duration(100) .attr("transform", (d, i) => "translate(#{@x(i)}, 0)")

  # datapointDrag: (d) =>
  #   registerKeyboardHandler(@keydown)
  #   document.onselectstart = () -> return false
  #   @selected = @dragged = d
  #   @updateChart()

  $hitX: null

  doHit: (x, distant) =>
    if distant < 0.3
      $candle = d3.select( d3.selectAll(".candle")[0][x] )
      if $candle
        @$hitX?.classed "hit", false
        @$hitX = $candle
        $candle.classed "hit", true
        @tip.show(@pData[x], $candle)
    else
      @$hitX?.classed "hit", false
      @$hitX = null
      @tip.hide()

  keydown: () =>
    return if not @selected
    switch (d3.event.keyCode)
      when 8, 46   # delete
        i = @points.indexOf(@selected)
        @points.splice(i, 1);
        # self.selected = self.points.length ? self.points[i > 0 ? i - 1 : 0] : null;
        @selected = if @points.length
          if i > 0 then @points[i - 1] else @points[0]
        else
          null
        @updateChart();
        
  xaxis_drag: () =>
    document.onselectstart = () -> false
    p = d3.mouse @plotArea()
    @downx = @x.invert(p[0]);

  yaxis_drag: (d) =>
    document.onselectstart = () -> false
    p = d3.mouse @plotArea()
    @downy = @y.invert(p[1]);

  getDataIndex: (cx) ->
    Math.floor(@x.invert(cx) + 0.5)

  visibleYExtend: -> 
    [first, last] = @x.domain()
    first = Math.floor first
    last = Math.floor last
    first = 0 if first < 0
    last = @pData.length if last > @pData.length

    ylow = Number.MAX_VALUE
    yhigh = Number.MIN_VALUE

    for i in [first...last]
      d = @pData[i]
      ylow = d[@PLOW] if d[@PLOW] < ylow
      yhigh = d[@PHIGH] if d[@PHIGH] > yhigh

    [yhigh, ylow ] # NOTE: inverted order max, min!

registerKeyboardHandler = (callback) ->
  callback = callback
  d3.select(window).on("keydown", callback)