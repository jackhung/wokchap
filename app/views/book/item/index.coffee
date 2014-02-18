'use strict'

ItemView = require('views/base/item')

module.exports = class BookItemView extends ItemView
  className: 'book-item-view'
  template: require('./template')
