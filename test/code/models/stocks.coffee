'use strict'

Stock = require('models/stock')
Stocks = require('models/stocks')

describe 'Stocks', ->

  beforeEach ->
    @stock = new Stock
    @stocks = new Stocks

  it '', ->


  afterEach ->
    @stock.dispose()
    @stocks.dispose()
