'use strict'

ChartOptions = require 'views/chart/chart-options'
PriceService = require 'views/chart/stock-price-service'

module.exports = class SimpleGraph

  constructor: (emid, options = {}) ->

    self = this
    @chart = document.getElementById emid
    # @$chart = $(emid)
    console.log "SimpleGraph#constructor #{emid}"
    console.debug @chart
    @$chart = $("##{emid}")
    @cx = @$chart.width()
    @cy = @$chart.height()
    # @cx = @chart.childWidth
    # @cy = @chart.childHeight
    # @cx = 800
    # @cy = 160

    @options = options
    @options.xmax = options.xmax || 30;
    @options.xmin = options.xmin || 0;
    @options.ymax = options.ymax || 10;
    @options.ymin = options.ymin || 0;
    @padding = 
      top:    if @options.title  then 40 else 20
      right:                 30
      bottom: if @options.xlabel then 60 else 35
      left:   if @options.ylabel then 70 else 45

    @size = {
      "width":  @cx - @padding.left - @padding.right,
      "height": @cy - @padding.top  - @padding.bottom
    };

    # x-scale
    @x = d3.scale.linear()
        .domain([@options.xmin, @options.xmax])
        .range([0, @size.width]);

    # drag x-axis logic
    @downx = Math.NaN;

    # y-scale (inverted domain)
    @y = d3.scale.linear()
        .domain([@options.ymax, @options.ymin])
        .nice()
        .range([0, @size.height])
        .nice();

    # drag y-axis logic
    @downy = Math.NaN;

    dragged: null
    selected: null

    @line = d3.svg.line()
        .x((d, i) => @x(@points[i].x))
        .y((d, i) => @y(@points[i].y))

    @setData()

    # vis is the 'g' element
    @vis = d3.select(@chart).append("svg") .attr("width",  @cx) .attr("height", @cy)
        .append("g")
          .attr("class", "plot-area")
          .attr("transform", "translate(" + @padding.left + "," + @padding.top + ")")

    # plot: the plot area for the data
    @plot = @vis.append("rect") .attr("width", @size.width) .attr("height", @size.height)
        .style("fill", "#EEEE99")
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
        .append("path")
            .attr("class", "line")
            .attr("d", @line(@points))
    
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
        .on("mousemove.drag", self.mousemove)
        .on("touchmove.drag", self.mousemove)
        .on("mouseup.drag",   self.mouseup)
        .on("touchend.drag",  self.mouseup)

    @redraw()

  setData: () ->
    xrange =  (@options.xmax - @options.xmin)
    yrange2 = (@options.ymax - @options.ymin) / 2
    yrange4 = yrange2 / 2
    datacount = @size.width/20

    @points = d3.range(datacount).map( (i) => 
      return { x: i * xrange / datacount, y: @options.ymin + yrange4 + Math.random() * yrange2 }; 
    , self)

  plotArea: () ->
    @vis.node() #@vis[0][0]

  plot_drag: () =>
    registerKeyboardHandler(@keydown)
    d3.select('body').style("cursor", "move")
    if (d3.event.altKey) 
      p = d3.mouse(@vis.node())
      newpoint = {};
      newpoint.x = @x.invert(Math.max(0, Math.min(@size.width,  p[0])));
      newpoint.y = @y.invert(Math.max(0, Math.min(@size.height, p[1])));
      @points.push(newpoint);
      @points.sort (a, b) ->
        return -1 if a.x < b.x
        return  1 if a.x > b.x
        return 0
      @selected = newpoint
      @update()
      d3.event.preventDefault()
      d3.event.stopPropagation()

  redraw: () =>
    tx = (d) => "translate(#{@x(d)},0)"
    ty = (d) => "translate(0,#{@y(d)})"
    stroke = (d) -> if d then "#ccc" else "#666"
    fx = @x.tickFormat(10)
    fy = @y.tickFormat(10)

    # Regenerate x-ticks…
    gx = @vis.selectAll("g.x") .data(@x.ticks(10), String) .attr("transform", tx)
    gx.select("text") .text(fx)
    gxe = gx.enter().insert("g", "a") .attr("class", "x") .attr("transform", tx)
    gxe.append("line") .attr("stroke", stroke) .attr("y1", 0) .attr("y2", @size.height)
    gxe.append("text") .attr("class", "axis")
        .attr("y", @size.height) .attr("dy", "1em")
        .attr("text-anchor", "middle")
        .text(fx)
        .style("cursor", "ew-resize")
        .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
        .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
        .on("mousedown.drag",  @xaxis_drag)
        .on("touchstart.drag", @xaxis_drag);
    gx.exit().remove();

    # Regenerate y-ticks…
    gy = @vis.selectAll("g.y") .data(@y.ticks(10), String) .attr("transform", ty)
    gy.select("text") .text(fy)
    gye = gy.enter().insert("g", "a") .attr("class", "y") .attr("transform", ty) .attr("background-fill", "#FFEEB6")
    gye.append("line") .attr("stroke", stroke) .attr("x1", 0) .attr("x2", @size.width)
    gye.append("text") .attr("class", "axis")
        .attr("x", -3) .attr("dy", ".35em")
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

  dataRenderStage: null

  update: () =>
    @dataRenderStage = null
    lines = @vis.select("path").attr("d", @line(@points));
          
    circle = @vis.select("svg").selectAll(".datapoint")
        .data(@points)

    dataPoint = circle.enter().append("g")
      .attr("class", "datapoint")
      .attr("transform", (d, i) => "translate(#{@x(d.x)},#{@y(d.y)})")

    # circle.enter().append("circle")
    dataPoint.append("circle")
        .attr("class", (d) =>
          if @dataRenderStage isnt "ENTERING"
            @dataRenderStage = "ENTERING"
            console.log "ENTERING: start"
          if d is @selected then "selected" else null )
        .attr("cx", 0.0 )
        .attr("cy", 0.0 )
        .attr("r", 6.0)
        .style("cursor", "ns-resize")
        .on("mousedown.drag",  @datapointDrag)
        .on("touchstart.drag", @datapointDrag)

    circle
      .transition() 
          .duration(300) 
          .attr("transform", (d, i) => "translate(#{@x(d.x)}, #{@y(d.y)})")
      # .attr("transform", (d, i) => "translate(#{@x(d.x)},#{@y(d.y)})")
    # circle
    #     .attr("class", (d) => 
    #       if @dataRenderStage isnt "UPDATING"
    #         @dataRenderStage = "UPDATING"
    #         console.log "UPDATING: start"
    #       if d is @selected then "selected" else null )
    #     .attr("cx",    (d) => @x(d.x) )
    #     .attr("cy",    (d) => @y(d.y) )

    circle.exit().remove();

    if (d3.event && d3.event.keyCode) 
      d3.event.preventDefault()
      d3.event.stopPropagation()

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
        @redraw();
  
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
        @redraw();
      
      d3.event.preventDefault();
      d3.event.stopPropagation();

  mouseup: () =>
    document.onselectstart = () -> return true
    d3.select('body').style("cursor", "auto");
    if (!isNaN(@downx))
      @redraw();
      @downx = Math.NaN;
      d3.event.preventDefault();
      d3.event.stopPropagation();

    if (!isNaN(@downy)) 
      @redraw();
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

  resetZoom: (p = 0.0) =>
    x0 = (@options.xmax - @options.xmin) * p
    @x.domain([x0, @options.xmax])
    @redraw()

  handleZoom: () =>
    translate = d3.event.translate
    scale = d3.event.scale
    ###
    ev = d3.event # contains: .translate[x,y], .scale
    if ev.scale == 1.0
      x.domain x0.domain()
      y.domain y0.domain()
      successfulTranslate = [0, 0]
    else
      xTrans = x0.range().map( (xVal) -> (xVal-ev.translate[0]) / ev.scale ).map(x0.invert)
      yTrans = y0.range().map( (yVal) -> (yVal-ev.translate[1]) / ev.scale ).map(y0.invert)
      xTransOk = xTrans[0] >= x0.domain()[0] and xTrans[1] <= x0.domain()[1]
      yTransOk = yTrans[0] >= y0.domain()[0] and yTrans[1] <= y0.domain()[1]
      if xTransOk
        x.domain xTrans
        successfulTranslate[0] = ev.translate[0]
      if yTransOk
        y.domain yTrans
        successfulTranslate[1] = ev.translate[1]
    zoomer.translate successfulTranslate
    ###
    console.debug translate, scale
    @y.domain(@visibleYExtend()).nice()
    @redraw()

  getDataIndex: (cx) ->
    Math.floor(@x.invert(cx) + 0.5)

  visibleYExtend: -> 
    first = @getDataIndex 0 + 1
    last = Math.min @getDataIndex @size.width - 1, @points.length
    console.log "#{first} .. #{last}"
    ys = for i in [0...@points.length] when @points[i].x >= first and @points[i].x <= last
      # console.debug i, @points[i]
      @points[i].y
    [_.max(ys) + 1 , _.min(ys) - 1 ] # NOTE: inverted order max, min!

registerKeyboardHandler = (callback) ->
  callback = callback
  d3.select(window).on("keydown", callback)