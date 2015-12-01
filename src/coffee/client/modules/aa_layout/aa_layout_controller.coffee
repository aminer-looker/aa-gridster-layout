#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../../underscore'
angular = require 'angular'

############################################################################################################

angular.module('aa-layout').controller 'AALayoutController', class AALayoutController

    init: ->
        layoutElements = (positionList)-> # do nothing

        @_columns = 12
        @_rowHeight = 100 # px

        @_elementCellPositions = []
        @_elementPxPositions = []

    # Public Methods ###################################################################

    refresh: ->
        @_recomputePositions()
        @layoutElements @_elementPxPositions

    # Property Methods #################################################################

    Object.defineProperties @prototype,

        width:
            get: -> return @_width
            set: (value)-> @_width = value

        columns:
            get: -> return @_columns
            set: (value)->
                if _.isString value then @_columns = parseInt(value)
                else if _.isNumber value then @_columns = value
                else throw new Error "expected a string or integer"

        rowHeight:
            get: -> return @_rowHeight
            set: (value)->
                if _.isString value then @_rowHeight = parseInt(value)
                else if _.isNumber value then @_rowHeight = value
                else throw new Error "expected a string or integer"

     # Private Methods #################################################################

     _recomputePostions: ->
         @_elementPxPositions = []

         # for position in @_elementCellPositions
