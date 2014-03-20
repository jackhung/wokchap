'use strict'

View = require('views/base/view')

module.exports = class IndexView extends View
  className: 'index-view'
  container: '#content-container'
  # container: "body"
  template: require('./template')
