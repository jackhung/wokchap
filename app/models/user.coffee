'use strict'

Model = require('models/base/model')
config = require "config"

module.exports = class User extends Model
  url: "/api/loginUser"
 