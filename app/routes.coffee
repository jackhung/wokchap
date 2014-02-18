'use strict'

module.exports = (match) ->
  match '', 'app#index'
  match 'book/:id', 'book#show'