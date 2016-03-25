module.exports = (env) ->

  hap = require 'hap-nodejs'
  Service = hap.Service
  Characteristic = hap.Characteristic

  SwitchAccessory = require('./switch')(env)

  ##
  # DimmerActuator
  ##
  class DimmerAccessory extends SwitchAccessory

    _dimlevel: null

    constructor: (device) ->
      super(device)
      @_dimlevel = device._dimlevel

      @getService(Service.Lightbulb)
        .getCharacteristic(Characteristic.Brightness)
        .on 'get', (callback) =>
          @handleReturnPromise(device.getDimlevel(), callback, null)

      device.on 'dimlevel', (dimlevel) =>
        @getService(Service.Lightbulb)
          .setCharacteristic(Characteristic.Brightness, dimlevel)

      @getService(Service.Lightbulb)
        .getCharacteristic(Characteristic.Brightness)
        .on 'set', (value, callback) =>
          if @_dimlevel is value
            env.logger.debug 'value ' + value + ' equals current dimlevel. Not changing.'
            callback()
            return
          env.logger.debug 'changing dimlevel to ' + value
          @_dimLevel = value
          @handleVoidPromise(device.changeDimlevelTo(value), callback)

    getDefaultService: =>
      return Service.Lightbulb
