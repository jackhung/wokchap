'use strict'

Collection = require('models/base/collection')
Book = require('./book')

module.exports = class Books extends Collection
  model: Book
