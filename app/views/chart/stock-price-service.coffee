
# http://money18.on.cc/chartdata/full/price/00106_price_full.txt
###
  chi_name: {values:深圳國際}
  code: {values:152}
  eng_name: {values:SHENZHEN INT'L}
  high: {,…}
  values: [0.485, 0.5, 0.52, 0.5, 0.49, 0.49, 0.495, 0.485, 0.48, 0.485, 0.485, 0.485, 0.485, 0.51, 0.51, 0.51,…]
  low: {,…}
  open: {,…}
  price: {,…}
  price_up_down: {,…}
  sma10: {,…}
  sma20: {,…}
  sma50: {,…}
  vol: {,…}
  x_axis: {,…}
###

$ = jQuery

# usage: new M18PriceService stkCode: "00119"
module.exports = class PriceService extends Backbone.Model
  defaults:
    stkCode: null

  yqlURL: "http://query.yahooapis.com/v1/public/yql"
  bollingURL: "http://boiling-ravine-9635.herokuapp.com/"

  priceFullURL: ->
    "http://money18.on.cc/chartdata/full/price/#{@stkCode()}_price_full.txt?jsonCompat=new"

  signalHistURLJSONP: ->
    "#{@bollingURL}/signals/get/#{@stkCode()}"

  signalHistURL: ->
    "#{@bollingURL}/signals/get/#{@stkCode()}"

  bullsSignalURL: ->
    "#{@bollingURL}/signals/history/#{@stkCode()}"

  stkCode: ->
    stkCode = @get("stkCode")
    throw "Error: attribute 'stkCode' is not set" unless stkCode
    return stkCode

  doFetch: (callback = null) ->
    query = "select * from json where url='#{@priceFullURL()}'"

    $.ajax
      url: @yqlURL,
      data: { q: query, format: "json" },
      cache:false,
      success: (data, status, xhr) =>
        if (not data.query.results)
          console.log "No Data Available!!"
          $("#humblefinance").html("<h1>No Data Available !!</h1>").fadeIn()
          return
        data = data.query.results.json
        for key, value of data
          data[key] = value.values || value.labels
        priceData = []; sma10 = []; sma20 = []; sma50 = []
        for date, i in data.x_axis
          d = moment date, "YYYYMMDD"
          close = parseFloat(data.price[i])
          open = parseFloat(data.open[i])
          high = parseFloat(data.high[i])
          low = parseFloat(data.low[i])
          vol = parseFloat(data.vol[i])
          if (open < 0) # handle suspend data
            open = high = low = close
          priceData.push [d.toString(), open, high, low, close, vol] unless isNaN(close) or isNaN(open)
          sma10.push parseFloat(data.sma10[i])
          sma20.push parseFloat(data.sma20[i])
          sma50.push parseFloat(data.sma50[i])
        @set priceData: priceData, name: data.chi_name, technicals: {sma10: sma10, sma20: sma20, sma50: sma50} 
        callback(data) if $.isFunction callback
        # @fetchSignalHist()
        @fetchRecentSignal()
        @fetchBullsSignal()

  fetchBullsSignal: ->
    $.ajax
      url: @bullsSignalURL()
      dataType: 'json'
      success: (data) =>
        signals = for signal in data.history
          d = moment signal[0], "MM/DD/YYYY"
          p = parseFloat signal[1].replace(/,/g, '')
          buySell = if signal[2] == "BUY" then 'B' else 'S'
          good = signal[3]
          ret = parseFloat(signal[4].replace(/,/g, ''))
          [d.toString(), p, buySell, good, ret]
        @set('signalHist', signals.reverse())

  recentSignalURL: ->
    "http://boiling-ravine-9635.herokuapp.com/daily_signal/get/#{@stkCode()}"

  fetchRecentSignal: ->
    $.ajax
      url: @recentSignalURL()
      dataType: 'jsonp'
      success: (data) =>
        signals = for record in data.docs
          record.data[@stkCode()].signal
        @set('dailySignals', signals.reverse().join(">"))


  # fetch signal using phantomjs
  fetchSignalHist: ->
    $.ajax
      url: @signalHistURL()
      dataType: 'json'
      success: (data) =>
        # console.log moment(data.history.sighist[0][0], "MM/DD/YYYY")
        signals = for signal in data.history.sighist
          d = moment signal[0], "MM/DD/YYYY"
          p = parseFloat signal[1]
          buySell = if signal[2] == "BUY" then 'B' else 'S'
          good = signal[3] == 'img/Check.gif'
          ret = parseFloat(signal[4].replace ',', '')
          [d.toString(), p, buySell, good, ret]
        @set('signalHist', signals.reverse())

  fetchSignalHistJSONP: ->
    $.ajax 
      url: @signalHistURLJSONP()
      dataType: "jsonp"
      success: (data) =>
        console.log data.sighist
      error: (xhr) =>
        console.log xhr

  # priceData [date, open, high, low, close, volume]
  addOrUpdatePriceData: (priceData) -> 
    attrPriceData = @get("priceData")
    if not attrPriceData  # no priceData
      return
    lastPriceData = attrPriceData.last()
    date = moment(priceData[0], "MM/DD/YYYY")
    lastDate = lastPriceData[0]
    if date.isSame(lastDate)
      attrPriceData[attrPriceData.length - 1] = priceData
    else
      @get("priceData").push(priceData)
    @trigger("change")

  addOrUpdateQuote: (quote) ->
    attrPriceData = @get("priceData")
    if not attrPriceData  # no priceData
      return
    lastRecord = attrPriceData[attrPriceData.length - 1]
    quoteDate = moment quote.date, "MM/DD/YYYY"
    lastDate = moment lastRecord[0]
    if quoteDate.isSame(lastDate)
      lastRecord[1] = quote.open
      lastRecord[2] = quote.high
      lastRecord[3] = quote.low
      lastRecord[4] = quote.close
      lastRecord[5] = quote.volume
    else
      @get("priceData").push [quoteDate, quote.open, quote.high, quote.low, quote.close, quote.volume]
    @trigger("change")

  getPriceData: ->
    @get("priceData")
