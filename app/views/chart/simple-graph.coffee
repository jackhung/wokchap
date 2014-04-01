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

  PDATE: 0
  POPEN: 1
  PHIGH: 2
  PLOW: 3
  PCLOSE: 4
  PVOL: 5

  # Real Stock Data ==============================================================
  onPriceData: (priceData) =>
    @model = priceData
    @pData = priceData.get("priceData")
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

  updateQuote: (quote) ->
    unless @pData
      console.log "priceData is not ready when receiving rtquote"
      return
    lastRecord = @pData[@pData.length - 1]
    quoteDate = moment quote.date, "MM/DD/YYYY"
    lastDate = moment lastRecord[0]
    if quoteDate.isSame(lastDate)
      lastRecord[1] = quote.open
      lastRecord[2] = quote.high
      lastRecord[3] = quote.low
      lastRecord[4] = quote.close
      lastRecord[5] = quote.volume
    else
      @pData.push [quoteDate, quote.open, quote.high, quote.low, quote.close, quote.volume]
    @resetZoom()

    console.log "#{quoteDate.format('YYYY/MM/DD')} #{lastDate.format('YYYY/MM/DD')}"

  # ================================================================================
  plotArea: () ->
    @vis.node() #@vis[0][0]

  plot_drag: () =>
    registerKeyboardHandler(@keydown)
    d3.select('body').style("cursor", "move")

  updateChart: () =>
    @drawCandle()

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
        .on("mousedown.drag",  @datapointDrag)
        .on("touchstart.drag", @datapointDrag)

    circle
      .transition() 
          .duration(300) 
          .attr("transform", (d, i) => "translate(#{@x(i)}, #{@y(d[@PCLOSE])})")

    circle.exit().remove();

    if (d3.event && d3.event.keyCode) 
      d3.event.preventDefault()
      d3.event.stopPropagation()


  allCandles: ->
    @vis.select("svg").selectAll(".candle")

  allStems: ->
    @allCandles().selectAll("line")

  allCandleStems: (topBottom = "top") ->
    @vis.select("svg").selectAll(".candle .stem.#{topBottom}")

  allCandleBodies: ->
    @vis.select("svg").selectAll(".candle .candle-body")

  drawCandle: ->
    candle = @vis.select("svg").selectAll(".candle").data(@pData)

    group = candle.enter().append("g") .attr("class", "candle")
    group.append("svg:line") 
      .attr("class", (d) => if d[@POPEN] > d[@PCLOSE] then "stem top price-down" else "stem top price-up")
    group.append("svg:line") 
      .attr("class", (d) => if d[@POPEN] > d[@PCLOSE] then "stem bottom price-down" else "stem bottom price-up")
    group.append("svg:rect")
      .attr("class", (d) => if d[@POPEN] > d[@PCLOSE] then "candle-body price-down" else "candle-body price-up")

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

  datapointDrag: (d) =>
    registerKeyboardHandler(@keydown)
    document.onselectstart = () -> return false
    @selected = @dragged = d
    @updateChart()

  mousemove: () =>
    p = d3.mouse @plotArea() 
    t = d3.event.changedTouches
    
    if (@dragged)
      @dragged.y = @y.invert(Math.max(0, Math.min(@size.height, p[1])));
      @updateChart();
    
    if (!isNaN(@downx)) 
      d3.select('body').style("cursor", "ew-resize");
      rupx = @x.invert(p[0])
      [xaxis1, xaxis2] = @x.domain()
      xaxis1 = 0 if (xaxis1 < 0)
      xaxis2 = @pData.length if xaxis2 >= @pData.length
      xextent = xaxis2 - xaxis1
      if (xextent < 30)
        xextent = 30
      if (rupx != 0)
        #changex = @downx / rupx; ?? avoid negative x? need to varify
        changex = (@downx - xaxis1) / (rupx - xaxis1);
        new_domain = [xaxis1, xaxis1 + (xextent * changex)]
        @x.domain(new_domain);
        @renderAxis();
  
      d3.event.preventDefault();
      d3.event.stopPropagation();
    
    if (!isNaN(@downy)) 
      d3.select('body').style("cursor", "ns-resize");
      rupy = @y.invert(p[1])
      yaxis1 = @y.domain()[1]
      yaxis2 = @y.domain()[0]
      yextent = yaxis2 - yaxis1
      if (rupy != 0) 
        changey = @downy / rupy;
        new_domain = [yaxis1 + (yextent * changey), yaxis1];
        @y.domain(new_domain);
        @renderAxis();
      
      d3.event.preventDefault();
      d3.event.stopPropagation();

  mouseup: () =>
    document.onselectstart = () -> return true
    d3.select('body').style("cursor", "auto");
    if (!isNaN(@downx))
      @renderAxis();
      @downx = Math.NaN;
      d3.event.preventDefault();
      d3.event.stopPropagation();

    if (!isNaN(@downy)) 
      @renderAxis();
      @downy = Math.NaN;
      d3.event.preventDefault();
      d3.event.stopPropagation();

    if (@dragged) 
      @dragged = null 

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

  resetZoom: (p = 150) =>
    x0 = Math.max @pData.length - @pData.length * (p / @pData.length), 60
    @x.domain([x0, @pData.length])
    @y.domain(@visibleYExtend()).nice()
    @renderAxis()


  zoomHandler: (domain) =>
    # translate = d3.event.translate
    # scale = d3.event.scale
    @x.domain(domain)
    @y.domain(@visibleYExtend()).nice()
    @renderAxis()

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
    console.log "SimpleGraph#visibleYExtend ----------- #{first} ... #{last}"
    for i in [first...last]
      d = @pData[i]
      ylow = d[@PLOW] if d[@PLOW] < ylow
      yhigh = d[@PHIGH] if d[@PHIGH] > yhigh
    console.log "#{first} .. #{last} max, min { #{yhigh} #{ylow}"
    [yhigh * 1.05 , ylow * 0.95 ] # NOTE: inverted order max, min!

registerKeyboardHandler = (callback) ->
  callback = callback
  d3.select(window).on("keydown", callback)