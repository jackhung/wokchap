'use strict'

module.exports = (match) ->
  match '', 'app#index'
  match 'book/:code', 'book#show'
  match 'news', 'news#list'
  match 'news/:link', 'news#show'