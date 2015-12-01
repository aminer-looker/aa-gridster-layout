#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../underscore'
angular = require 'angular'

############################################################################################################

angular.module('aa-layout').controller 'AALayoutController', class AALayoutController

    init: ->
        layoutElements = (positionList)-> # do nothing

        @_columns = 12
        @_rowHeight = 100 # px

    # Public Methods ###################################################################

    refresh: ->
        @_recomputePositions()
        @layoutElements @_positions

    # Property Methods #################################################################

    Object.defineProperties @prototype,

        columns:
            get: -> return @_columns
            set: (value)->
                if _.isString value then @_columns = parseInt(value)
                else _.isNumber value then @_columns = value
                else throw new Error "expected a string or integer"

        rowHeight:
            get: -> return @_rowHeight
            set: (value)->
                if _.isString value then @_rowHeight = parseInt(value)
                else _.isNumber value then @_rowHeight = value
                else throw new Error "expected a string or integer"

     # Private Methods #################################################################

     _recomputePostions: ->
         # TODO: Figure out the proper top/left/width/height based upon grid postion
