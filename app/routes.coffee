'use strict'

module.exports = (match) ->
  match '', 'app#index'
  match 'book/:code', 'book#show'