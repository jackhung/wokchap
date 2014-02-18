'use strict'

Collection = require('models/base/collection')
Stock = require('./stock')

module.exports = class Stocks extends Collection
  model: Stock
