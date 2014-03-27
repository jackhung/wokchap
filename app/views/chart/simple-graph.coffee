'use strict'
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
      bottom: if @options.xlabel then 60 else 10
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

    xrange =  (@options.xmax - @options.xmin)
    yrange2 = (@options.ymax - @options.ymin) / 2
    yrange4 = yrange2 / 2
    datacount = @size.width/30

    @points = d3.range(datacount).map( (i) => 
      return { x: i * xrange / datacount, y: @options.ymin + yrange4 + Math.random() * yrange2 }; 
    , self)

    # chart = document.getElementById emid
    @vis = d3.select(@chart).append("svg")
    # @vis = d3.select(@$chart).append("svg")
        .attr("width",  @cx)
        .attr("height", @cy)
        .append("g")
          .attr("transform", "translate(" + @padding.left + "," + @padding.top + ")")
    @plot = @vis.append("rect")
        .attr("width", @size.width)
        .attr("height", @size.height)
        .style("fill", "#EEEEEE")
        .attr("pointer-events", "all")
        .on("mousedown.drag", @plot_drag)
        .on("touchstart.drag", @plot_drag)
        @plot.call(d3.behavior.zoom().x(@x).y(@y).on("zoom", @redraw()))

    @vis.append("svg")
        .attr("top", 0)
        .attr("left", 0)
        .attr("width", @size.width)
        .attr("height", @size.height)
        .attr("viewBox", "0 0 "+@size.width+" "+@size.height)
        .attr("class", "line")
        .append("path")
            .attr("class", "line")
            .attr("d", @line(@points))
    
    # add Chart Title
    if (@options.title)
      @vis.append("text")
          .attr("class", "axis")
          .text(@options.title)
          .attr("x", @size.width/2)
          .attr("dy","-0.8em")
          .style("text-anchor","middle")

    # Add the x-axis label
    if (@options.xlabel) 
      @vis.append("text")
          .attr("class", "axis")
          .text(@options.xlabel)
          .attr("x", @size.width/2)
          .attr("y", @size.height)
          .attr("dy","2.4em")
          .style("text-anchor","middle");

    # add y-axis label
    if (@options.ylabel) 
      @vis.append("g").append("text")
          .attr("class", "axis")
          .text(@options.ylabel)
          .style("text-anchor","middle")
          .attr("transform","translate(" + -40 + " " + @size.height/2+") rotate(-90)");
    

    d3.select(@chart)
        .on("mousemove.drag", self.mousemove())
        .on("touchmove.drag", self.mousemove())
        .on("mouseup.drag",   self.mouseup())
        .on("touchend.drag",  self.mouseup());

    @redraw()();


  plot_drag: () =>
    registerKeyboardHandler(@keydown())
    d3.select('body').style("cursor", "move")
    if (d3.event.altKey) 
      p = d3.mouse(@vis.node())
      newpoint = {};
      newpoint.x = @x.invert(Math.max(0, Math.min(@size.width,  p[0])));
      newpoint.y = @y.invert(Math.max(0, Math.min(@size.height, p[1])));
      @points.push(newpoint);
      @points.sort( (a, b) ->
        return -1 if a.x < b.x
        return  1 if a.x > b.x
        return 0
      )
      @selected = newpoint
      @update()
      d3.event.preventDefault()
      d3.event.stopPropagation()

  redraw: () =>
    console.log "REDRAWing"
    self = this;
    return () ->
      tx = (d) ->
        return "translate(" + self.x(d) + ",0)"
      ty = (d) ->
        return "translate(0," + self.y(d) + ")"
      stroke = (d) ->
        return if d then "#ccc" else "#666"
      fx = self.x.tickFormat(10)
      fy = self.y.tickFormat(10)

      # Regenerate x-ticks…
      gx = self.vis.selectAll("g.x")
          .data(self.x.ticks(10), String)
          .attr("transform", tx)

      gx.select("text")
          .text(fx)

      gxe = gx.enter().insert("g", "a")
          .attr("class", "x")
          .attr("transform", tx)

      gxe.append("line")
          .attr("stroke", stroke)
          .attr("y1", 0)
          .attr("y2", self.size.height)

      gxe.append("text")
          .attr("class", "axis")
          .attr("y", self.size.height)
          .attr("dy", "1em")
          .attr("text-anchor", "middle")
          .text(fx)
          .style("cursor", "ew-resize")
          .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
          .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
          .on("mousedown.drag",  self.xaxis_drag())
          .on("touchstart.drag", self.xaxis_drag());

      gx.exit().remove();

      # Regenerate y-ticks…
      gy = self.vis.selectAll("g.y")
          .data(self.y.ticks(10), String)
          .attr("transform", ty)

      gy.select("text")
          .text(fy);

      gye = gy.enter().insert("g", "a")
          .attr("class", "y")
          .attr("transform", ty)
          .attr("background-fill", "#FFEEB6")

      gye.append("line")
          .attr("stroke", stroke)
          .attr("x1", 0)
          .attr("x2", self.size.width)

      gye.append("text")
          .attr("class", "axis")
          .attr("x", -3)
          .attr("dy", ".35em")
          .attr("text-anchor", "end")
          .text(fy)
          .style("cursor", "ns-resize")
          .on("mouseover", (d) -> d3.select(this).style("font-weight", "bold"))
          .on("mouseout",  (d) -> d3.select(this).style("font-weight", "normal"))
          .on("mousedown.drag",  self.yaxis_drag())
          .on("touchstart.drag", self.yaxis_drag())

      gy.exit().remove();
      self.plot.call(d3.behavior.zoom().x(self.x).y(self.y).on("zoom", self.redraw()));
      self.update();    



  update: () ->
    self = this;
    lines = this.vis.select("path").attr("d", this.line(this.points));
          
    circle = this.vis.select("svg").selectAll("circle")
        .data(this.points, (d) -> return d)

    circle.enter().append("circle")
        .attr("class", (d) -> if d is self.selected then "selected" else null )
        .attr("cx",    (d) -> return self.x(d.x); )
        .attr("cy",    (d) -> return self.y(d.y); )
        .attr("r", 10.0)
        .style("cursor", "ns-resize")
        .on("mousedown.drag",  self.datapoint_drag())
        .on("touchstart.drag", self.datapoint_drag());

    circle
        .attr("class", (d) -> if d is self.selected then "selected" else null )
        .attr("cx",    (d) -> return self.x(d.x); )
        .attr("cy",    (d) -> return self.y(d.y); )

    circle.exit().remove();

    if (d3.event && d3.event.keyCode) 
      d3.event.preventDefault();
      d3.event.stopPropagation()

  datapoint_drag: () ->
    self = this;
    return (d) ->
      registerKeyboardHandler(self.keydown());
      document.onselectstart = () -> return false
      self.selected = self.dragged = d
      self.update()

  mousemove: () ->
    self = this
    return () ->
      p = d3.mouse(self.vis[0][0])
      t = d3.event.changedTouches
      
      if (self.dragged)
        self.dragged.y = self.y.invert(Math.max(0, Math.min(self.size.height, p[1])));
        self.update();
      
      if (!isNaN(self.downx)) 
        d3.select('body').style("cursor", "ew-resize");
        rupx = self.x.invert(p[0])
        xaxis1 = self.x.domain()[0]
        xaxis2 = self.x.domain()[1]
        xextent = xaxis2 - xaxis1
        if (rupx != 0)

          changex = self.downx / rupx;
          new_domain = [xaxis1, xaxis1 + (xextent * changex)];
          self.x.domain(new_domain);
          self.redraw()();
    
        d3.event.preventDefault();
        d3.event.stopPropagation();
      
      if (!isNaN(self.downy)) 
        d3.select('body').style("cursor", "ns-resize");
        rupy = self.y.invert(p[1])
        yaxis1 = self.y.domain()[1]
        yaxis2 = self.y.domain()[0]
        yextent = yaxis2 - yaxis1
        if (rupy != 0) 
          changey = self.downy / rupy;
          new_domain = [yaxis1 + (yextent * changey), yaxis1];
          self.y.domain(new_domain);
          self.redraw()();
        
        d3.event.preventDefault();
        d3.event.stopPropagation();

  mouseup: () ->
    self = this;
    return () ->
      document.onselectstart = () -> return true
      d3.select('body').style("cursor", "auto");
      d3.select('body').style("cursor", "auto");
      if (!isNaN(self.downx))
        self.redraw()();
        self.downx = Math.NaN;
        d3.event.preventDefault();
        d3.event.stopPropagation();

      if (!isNaN(self.downy)) 
        self.redraw()();
        self.downy = Math.NaN;
        d3.event.preventDefault();
        d3.event.stopPropagation();

      if (self.dragged) 
        self.dragged = null 

  keydown: () ->
    self = this;
    return () ->
      return if not self.selected
      switch (d3.event.keyCode)
        when 8, 46   # delete
          i = self.points.indexOf(self.selected)
          self.points.splice(i, 1);
          # self.selected = self.points.length ? self.points[i > 0 ? i - 1 : 0] : null;
          self.selected = if self.points.length
            if i > 0 then self.points[i - 1] else self.points[0]
          else
            null
          self.update();
        
  xaxis_drag: () ->
    self = this;
    return (d) ->
      document.onselectstart = () -> false
      p = d3.mouse(self.vis[0][0]);
      self.downx = self.x.invert(p[0]);

  yaxis_drag: (d) ->
    self = this;
    return (d) ->
      document.onselectstart = () -> false
      p = d3.mouse(self.vis[0][0]);
      self.downy = self.y.invert(p[1]);



registerKeyboardHandler = (callback) ->
  callback = callback
  d3.select(window).on("keydown", callback)