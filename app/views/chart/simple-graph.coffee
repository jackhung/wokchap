'use strict'

ChartOptions = require 'views/chart/chart-options'
PriceService = require 'views/chart/stock-price-service'
View = require 'views/base/view'

module.exports = class SimpleGraph extends View



  constructor: (emid, options = {}) ->

    @chart = document.getElementById emid
    # @$chart = $(emid)
    console.log "SimpleGraph#constructor #{emid}"
    console.debug @chart
    @$chart = $("##{emid}")
    @cx = @$chart.width()
    @cy = @$chart.height()

    @options = options

    @padding = 
      top:    if @options.title  then 40 else 5
      right:                 30
      bottom: if @options.xlabel then 60 else 35
      left:   if @options.ylabel then 70 else 45

    @size = {
      "width":  @cx - @padding.left - @padding.right,
      "height": @cy - @padding.top  - @padding.bottom
    };

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

    @initChartElements()
    @redrawP()

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

  redrawP: () =>
    tx = (d) => "translate(#{@x(d)},0)"
    ty = (d) => "translate(0,#{@y(d)})"
    stroke = (d) -> if d then "#ccc" else "#666"
    fx = @x.tickFormat(8)
    fy = @y.tickFormat(10)

    # Regenerate x-ticks…
    gx = @bgPane.selectAll("g.x") .data(@x.ticks(10), String) .attr("transform", tx)
    gx.select("text") .text((i) => moment(@pData[+i][0]).format("MMM-DD"))
    gxe = gx.enter().insert("g", "a") .attr("class", "x") .attr("transform", tx)
    gxe.append("line") .attr("stroke", stroke) .attr("y1", 0) .attr("y2", @size.height)
    gxe.append("text") .attr("class", "axis")
        .attr("y", @size.height) .attr("dy", "1em")
        .attr("text-anchor", "middle")
        .text((i) => moment(@pData[+i][0]).format("MMM-DD"))
        .style("cursor", "ew-resize")
        .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
        .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
        .on("mousedown.drag",  @xaxis_drag)
        .on("touchstart.drag", @xaxis_drag);
    gx.exit().remove();

    # Regenerate y-ticks…
    gy = @bgPane.selectAll("g.y") .data(@y.ticks(8), String) .attr("transform", ty)
    # gy.select("text") .text(fy)
    gye = gy.enter().insert("g", "a") .attr("class", "y") .attr("transform", ty) .attr("background-fill", "#FFEEB6")
    gye.append("line") .attr("stroke", stroke) .attr("x1", 0) .attr("x2", @size.width)
    gye.append("text") .attr("class", "axis")
        .attr("x", @size.width + 20) .attr("dy", ".35em")
        .attr("text-anchor", "end")
        .text(fy)
        .style("cursor", "ns-resize")
        .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
        .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
        .on("mousedown.drag",  @yaxis_drag)
        .on("touchstart.drag", @yaxis_drag)
    gy.exit().remove();

    @zoom = d3.behavior.zoom().x(@x).on("zoom", @handleZoom)
    @plot.call(@zoom)
    @update();    


  initChartElements: () ->
    throw "Already initialized error!" if $(@chart).find('svg').length

    @svg = d3.select(@chart).append("svg") .attr("width",  @cx) .attr("height", @cy)

    @bgPane = @svg.append("g")
          .attr("class", "plot-background")
          .attr("transform", "translate(" + @padding.left + "," + @padding.top + ")")
    @bgPane.append("rect") .attr("width", @size.width) .attr("height", @size.height)

    # vis is the 'g' element
    @vis = @svg.append("g")
          .attr("class", "plot-area")
          .attr("transform", "translate(" + @padding.left + "," + @padding.top + ")")

    # plot: the plot area for the data
    @plot = @vis.append("rect") .attr("width", @size.width) .attr("height", @size.height)
        .style("fill", "none")
        .attr("pointer-events", "all")
        .on("mousedown.drag", @plot_drag)
        .on("touchstart.drag", @plot_drag)

    @zoom = d3.behavior.zoom().x(@x).on("zoom", @handleZoom)
    @plot.call(@zoom)

    # the line path, class='line'
    @vis.append("svg")
        .attr("top", 0) .attr("left", 0) .attr("width", @size.width) .attr("height", @size.height)
        .attr("viewBox", "0 0 "+@size.width+" "+@size.height)
        .attr("class", "line")

    
    # add Chart Title
    if (@options.title)
      @vis.append("text") .attr("class", "axis") .text(@options.title) .attr("x", @size.width/2)
          .attr("dy","-0.8em") .style("text-anchor","middle")

    # Add the x-axis label
    if (@options.xlabel) 
      @vis.append("text") .attr("class", "axis") .text(@options.xlabel) .attr("x", @size.width/2) .attr("y", @size.height)
          .attr("dy","2.4em")
          .style("text-anchor","middle");

    # add y-axis label
    if (@options.ylabel) 
      @vis.append("g").append("text") .attr("class", "axis") .text(@options.ylabel) .style("text-anchor","middle")
          .attr("transform","translate(" + -40 + " " + @size.height/2+") rotate(-90)");

    d3.select(@chart)
        .on("mousemove.drag", @mousemove)
        .on("touchmove.drag", @mousemove)
        .on("mouseup.drag",   @mouseup)
        .on("touchend.drag",  @mouseup)

  # ================================================================================
  plotArea: () ->
    @vis.node() #@vis[0][0]

  plot_drag: () =>
    registerKeyboardHandler(@keydown)
    d3.select('body').style("cursor", "move")

  update: () =>
    @dataRenderStage = null
    # lines = @vis.select("path").attr("d", @line(@pData));
    # @drawCircle()
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
    rectHeightRatio = Math.abs(@y(1) - @y(0))
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
    @update()

  mousemove: () =>
    p = d3.mouse @plotArea() 
    t = d3.event.changedTouches
    
    if (@dragged)
      @dragged.y = @y.invert(Math.max(0, Math.min(@size.height, p[1])));
      @update();
    
    if (!isNaN(@downx)) 
      d3.select('body').style("cursor", "ew-resize");
      rupx = @x.invert(p[0])
      xaxis1 = @x.domain()[0]
      xaxis2 = @x.domain()[1]
      xextent = xaxis2 - xaxis1
      if (rupx != 0)
        #changex = @downx / rupx; ?? avoid negative x? need to varify
        changex = (@downx - xaxis1) / (rupx - xaxis1);
        new_domain = [xaxis1, xaxis1 + (xextent * changex)];
        @x.domain(new_domain);
        @redrawP();
  
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
        @redrawP();
      
      d3.event.preventDefault();
      d3.event.stopPropagation();

  mouseup: () =>
    document.onselectstart = () -> return true
    d3.select('body').style("cursor", "auto");
    if (!isNaN(@downx))
      @redrawP();
      @downx = Math.NaN;
      d3.event.preventDefault();
      d3.event.stopPropagation();

    if (!isNaN(@downy)) 
      @redrawP();
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
        @update();
        
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
    @redrawP()

  handleZoom: () =>
    translate = d3.event.translate
    scale = d3.event.scale
    @y.domain(@visibleYExtend()).nice()
    @redrawP()

  getDataIndex: (cx) ->
    Math.floor(@x.invert(cx) + 0.5)

  visibleYExtend: -> 
    first = @getDataIndex 0 + 1
    last = Math.min @getDataIndex @size.width - 1, @pData.length
    
    ylow = Number.MAX_VALUE
    yhigh = Number.MIN_VALUE
    for i in [0...@pData.length] when i >= first and i <= last
      ylow = @pData[i][@PLOW] if @pData[i][@PLOW] < ylow
      yhigh = @pData[i][@PHIGH] if @pData[i][@PHIGH] > yhigh
    console.log "#{first} .. #{last} max, min { #{yhigh} #{ylow}"
    [yhigh * 1.1 , ylow * 0.9 ] # NOTE: inverted order max, min!

registerKeyboardHandler = (callback) ->
  callback = callback
  d3.select(window).on("keydown", callback)