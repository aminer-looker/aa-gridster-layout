#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../../underscore'
angular = require 'angular'

############################################################################################################

angular.module('aa-layout').controller 'AALayoutController', class AALayoutController

    constructor: ->
        layoutElements = (positionList)-> # do nothing

        @_columns   = 12
        @_rowHeight = 100 # px
        @_width     = 1000
        @_height    = 1000

        @_elementCellPositions = []
        @_elementPxPositions   = []

    # Public Methods ###################################################################

    updateElements: (elementCellPositions)->
        @_elementCellPositions = elementCellPositions
        @refresh()

    refresh: ->
        @_recomputePostions()
        @layoutElements @_elementPxPositions

    # Property Methods #################################################################

    Object.defineProperties @prototype,

        height:
            get: -> return @_height
            set: (value)-> @_height = value

        width:
            get: -> return @_width
            set: (value)-> @_width = value

        columns:
            get: -> return @_columns
            set: (value)->
                value ?= 0

                if _.isString value
                    @_columns = parseInt(value)
                else if _.isNumber value
                    @_columns = value
                else
                    throw new Error "expected a string or integer"

        rowHeight:
            get: -> return @_rowHeight
            set: (value)->
                value ?= 0

                if _.isString value
                    @_rowHeight = parseInt(value)
                else if _.isNumber value
                    @_rowHeight = value
                else
                    throw new Error "expected a string or integer"

     # Private Methods #################################################################

    _recomputePostions: ->
        return unless @_elementCellPositions.length > 0

        xScale = @_width / @_columns
        yScale = @_rowHeight

        @_elementPxPositions = []
        for position in @_elementCellPositions
            px = new ElementPosition
            @_elementPxPositions.push px

            px.x      = position.x * xScale
            px.y      = position.y * yScale
            px.width  = position.width * xScale
            px.height = position.height * yScale
