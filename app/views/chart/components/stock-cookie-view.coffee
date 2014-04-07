View = require 'views/base/view'
ViewHelper = require "lib/view-helper"

module.exports = class StockCookieView extends View
  _.extend @prototype, ViewHelper

  autoRender: false
  el: "#stock-cookies .cookie-list"
  remembered: null
  stockCookieName: "STOCKS_COOKIE"
  sort: false

  listen:
    "change model": "render"

  events:
    "click .stock-ref" : "openChart"
      
  initialize: ->
    $(document).delegate('#stock-cookies .cus-wrench', "click", @toggleSort)

  setCookie: (code) ->
    codes = $.cookie(@stockCookieName)?.split("-") || []
    if (index = codes.indexOf(code)) > 0
      codes.splice(index, 1) 
    codes.unshift(code) unless index is 0 # skip if index == 0, already at the beginning
    codes.pop() if codes.length > 50
    $.cookie(@stockCookieName, codes.join("-"), { expires: 30, path: '/' })

  render: (force = false) =>
    @setCookie @model.get("stkCode") if @model.get("name")
    cookie = $.cookie(@stockCookieName)
    return if not cookie or cookie == @remembered && !force
    @remembered = cookie 

    codes = cookie.split("-")
    codes.sort() if @sort

    lis = for code in codes
      "<span class='stock-ref badge' ref='#{code}'> #{code} </span>"
    @$el.html lis.join(" ") + " <span>&nbsp;&nbsp;<i class='icon_btn_ cus-wrench'></i></span>"

    @initStockRef @$el.find(".stock-ref")

  toggleSort: () =>
    @sort = !@sort
    @render(true)

  cookieClicked: (e) ->
    e.preventDefault()
    $target = $(this)
    $target.btOff()
    code = $target.attr('code')
    # window.open "#{WokChart.actionMap.wokChart}#{code}", "_blank"
