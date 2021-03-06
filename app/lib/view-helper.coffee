'use strict'

utils = require('./utils')

ViewHelper = 
  initStockRef: (elems) ->
    elems.each (ref) ->
      $this = $(@)
      code = $this.attr("ref")
      $(" <i class='cus-chart-line stock-tip' ref='#{code}'></i> ").insertAfter($this)

    @initTip()  # see ViewHelper

  initTip: () ->
    self = @
    @$el.off "shown.bs.popover", ".stock-tip"
    @$el.find(".stock-tip").each (e) ->
      $this = $(@)
      stkCode = $this.attr("ref")
      console.log "init popover for #{stkCode}"
      $this.popover
        placement: "auto top"
        # selector: "#stk-tip-popover"
        trigger: "hover"
        html: true
        content: -> self.tipPopoverContent(stkCode)
        # selector: "#stk-tip-content-container"

    @delegate "shown.bs.popover", ".stock-tip", @showTip

  showTip: (e) ->
    $elm = $(e.target)
    stkCode = $elm.attr("ref")

    @fetchLatestQuote stkCode
    console.debug "ViewHelper#showTip", stkCode

  tipPopoverContent: (stkCode) ->
    img = "<img class='rtq_chart_png' src='http://img.finance.qq.com/images/hq_parts_little4/hongkong/#{stkCode}.png'/>"
    """
      <div class='rtq-tip-wrapper'>
      <span class="rtq-code">#{stkCode}</span>: <span class="rtq-name">...</span>
      <div class='clearfix'></div>
      <span class="rtq-price">...</span><span class="rtq-change">...</span>
      </div>
      #{img}
      <div>
        <span class="rtq-time">...</span>
      </div>
      <div>
        <img class="rtq_daily_chart" src="http://www.etnet.com.hk/www/tc/common/chart_daily.php?code=#{stkCode}"/>
      </div>
      """

  fetchLatestQuote: (code) ->
    $box = $(".popover-content")
    $.ajax
      url: "http://qt.gtimg.cn?q=hk#{code}"
      dataType: "script"
      success: =>
        v_data = window["v_hk#{code}"].split("~")
        # console.log "#{code} #{v_data[19]} date:#{v_data[30]}"
        $box.find(".rtq-name").html(v_data[1])
        $box.find(".rtq-time").html(v_data[30].substr(5))
        [change, percent] = v_data[31..32]
        $box.find(".rtq-change").html("#{change} #{percent}%").addClass(if (change[0] is '-') then "price-down" else "price-up")
        $box.find(".rtq-price").html("#{v_data[35]}")

  formatVol: (v) ->
    f = d3.formatPrefix(v)
    "#{f.scale(v).toFixed(3)}#{f.symbol}"

  formatChange: (c, p) ->
    d = c - p
    prct = (d / p * 100).toFixed(2)
    "<span #{if d < 0 then 'class="price-down"' else ''}>#{d.toFixed(3)} #{prct}%</span>"

  openChart: (e) ->
    $this = $(e.target)
    code = $this.attr("ref")
    utils.redirectTo 'chart#show', {code: code}

module.exports = ViewHelper