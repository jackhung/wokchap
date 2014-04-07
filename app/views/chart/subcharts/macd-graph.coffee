'use strict'

ChartOptions = require 'views/chart/chart-options'
ChartView = require 'views/chart/base-chart'

module.exports = class MacdGraph extends ChartView

  defaults:
    yticks: 5

  initialize: (options) ->
    super

  # Real Stock Data ==============================================================
  onPriceDataReady: () =>
    @macd = new MACD(12, 26, 9).calculate(@model.get("priceData"))
    super
    # x-scale
    @x = d3.scale.linear()
        .domain([0, @pData.length])
        .range([0, @size.width]);

    # @ymin = d3.min @pData, (d) => d[@PVOL]
    # @ymax = d3.max @pData, (d) => d[@PVOL]
    # y-scale (inverted domain)
    @y = d3.scale.linear()
        # .domain([@ymax, @ymin])
        .range([0, @size.height])
        .nice();

    # @ymin = d3.min @pData, (d) => d[@PVOL]
    # @ymax = d3.max @pData, (d) => d[@PVOL]
    @y2 = d3.scale.linear()
      .range([0, @size.height]).nice()

    # @initChartElements()

    @renderAxis()

  # ================================================================================

  updateChart: () =>
    @drawMacd()

  drawMacd: () ->
    @drawBar()
    for line in ["macd", "macds"]
      data = @macd[line]
      @drawLine line, data

  drawBar: ->
    rectWidth = Math.abs(@x(1) - @x(0) ) * 0.6


    yZero = @y(0)
    # @rects = @drawingArea.selectAll("rect")
    #   .data(data["macd2"])
    #   .enter().append("rect")
    #   .attr("x", (d, i) => @xScale(i) - barWidth * .5)
    #   .attr "y", (d) => 
    #     if d >= 0
    #       @yScale( d )
    #     else
    #       yZero
    #   .attr("width", barWidth)
    #   .attr "height", (d, i) =>
    #     if d >= 0 
    #       yZero - @yScale(d)
    #     else
    #       @yScale(d) - yZero
    #   .classed("down", (d) -> d < 0.0)
    #   .on("mouseover", (d,i) -> console.log "#{i}: #{d}")

    y0 = @y(0)

    fHeight = (d, i) =>
        h = if isNaN d
          0
        else 
          @y(d) - yZero
        # console.log "#{i}: negative height #{h}" if h < 0
        Math.abs h

    @bars = @vis.select("svg").selectAll(".macd-bar").data(@macd["macd2"])
    @bars
      .enter().append("rect")
      .attr("class", "macd-bar")
      # .attr("x", -rectWidth/2)
      # .attr("y", y0)
      # .attr("width", rectWidth)
      # .attr "height", (d, i) => 
      #   @size.height - (@y2(d or 0))
      .classed("down", (d) => d < 0)
      # .on("mouseover", (d,i) -> console.log "macd #{i}: #{d}")
    @bars
      .attr("x", -rectWidth/2)
      .attr("width", rectWidth)
      .attr "y", (d) => 
        if isNaN d
          yZero
        else if d >= 0
          @y(d)
        else
          yZero
      .attr "height", fHeight


    @bars.exit().remove()
    @bars .transition() .duration(100) .attr("transform", (d, i) => "translate(#{@x(i)}, 0)")

  yaxis_drag: (d) =>
    document.onselectstart = () -> false
    p = d3.mouse @plotArea()
    @downy = @y.invert(p[1]);

  getDataIndex: (cx) ->
    Math.floor(@x.invert(cx) + 0.5)

  yAxisLabel: () =>
    (d) => f = d3.formatPrefix(d); "#{f.scale(d)}#{f.symbol}"

  visibleYExtend: -> 
    [first, last] = @x.domain()
    first = Math.floor first
    last = Math.floor last
    first = 0 if first < 0
    last = @pData.length if last > @pData.length

    ylow = Number.MAX_VALUE
    yhigh = Number.MIN_VALUE
    for line in ["macd", "macds"]
      data = @macd[line]
      for i in [first...last]
        d = data[i]
        ylow = d if d < ylow
        yhigh = d if d > yhigh
    
    ymin = d3.min @macd["macd2"]
    ymax = d3.max @macd["macd2"]
    @y2.domain [ymin, ymax]

    [yhigh * 1.01, ylow * 0.99] # NOTE: inverted order max, min!

# =============================================================================================
class EMA 
  constructor: (@period) ->
    @value = 0.0;
    @alpha = 2.0 / (@period + 1);
  calculate: (prices) ->
    ema = []
    # ema[@period - 2] = prices.slice(0,@period - 1).inject(0, function(a,b) {return a + b;}) / (@period - 1);
    ema[@period - 2] = d3.sum (prices.slice(0, @period - 1)) / (@period - 1)
    for i in [(@period - 1)..prices.length]
      ema[i] = ema[i-1] * (1 - @alpha) + prices[i] * @alpha 
    # for (var i = this.period - 1; i < prices.length; i++) {
    #   ema[i] = ema[i-1] * (1 - this.alpha) + prices[i] * this.alpha; 
    # }
    ema

class MACD  # 12, 26, 9
  constructor: (@fastPeriod, @slowPeriod, @signalPeriod) ->
    @fastEMA = new EMA(@fastPeriod)
    @slowEMA = new EMA(@slowPeriod)
    @alpha = 2.0 / (@signalPeriod + 1)
  calculate: (ohlc) ->
    prices = for r in ohlc
      r[4]
    fast = @fastEMA.calculate(prices)
    slow = @slowEMA.calculate(prices)
    macd = for i in [0..prices.length]
      fast[i] - slow[i]
    signal = []

    signal[@slowPeriod + @signalPeriod - 2] = 
      d3.sum(macd.slice(@slowPeriod - 1, @slowPeriod + @signalPeriod )) / (@signalPeriod - 1)
      # macd.slice(@slowPeriod -1, @slowPeriod + @signalPeriod).inject(0, function(a,b) {return a+b;}
      #     ) / (this.signalPeriod - 1);
    macdData = []
    macd2 = []
    signalData = []
    macdData[@slowPeriod + @signalPeriod - 2] = 0
    macd2[@slowPeriod + @signalPeriod - 2] = 0
    signalData[@slowPeriod + @signalPeriod - 2] = 0

    for i in [(@slowPeriod + @signalPeriod - 1)..prices.length - 1] # TODO why prices.length - 1?
      signal[i] = signal[i-1] * (1 - @alpha) + macd[i] * @alpha;
      macdData.push macd[i]
      signalData.push signal[i]
      macd2.push( macd[i] - signal[i] )

    # for (var i = @slowPeriod + @signalPeriod - 1; i < prices.length; i++) {
    #   signal[i] = signal[i-1] * (1 - @alpha) + macd[i] * @alpha;
    #   macdData.push([i, macd[i]]);
    #   signalData.push([i, signal[i]]);
    #   macd2.push([i, macd[i] - signal[i]]);
    #   //console.log(macd[i] + " " + signal[i] + " " + (signal[i] - macd[i]));
    # }
    {macd: macdData, macds: signalData, macd2: macd2}