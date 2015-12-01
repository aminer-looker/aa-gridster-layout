#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../../underscore'
angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'GridLayout', (ElementPosition)->

    class GridLayout

        constructor: ($parentEl)->
            @_columns = 12
            @_rowHeight = 100 # px
            @_margin = 5
            @_width = $parentEl.width()
            @_$parentEl = $parentEl

            @_initializeElements @_findGridElements $parentEl

        # Public Methods ###############################################################

        layoutElements: ->
            @_refreshPxFromCellPositions()
            @_refreshDomFromPxPositions()

        # Property Methods #############################################################

        Object.defineProperties @prototype,

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

            margin:
                get: -> return @_margin
                set: (value)->
                    value ?= 0

                    if _.isString value
                        @_margin = parseInt(value)
                    else if _.isNumber value
                        @_margin = value
                    else
                        throw new Error "expected a string or integer"

        # Private Methods #############################################################

        _convertCellToPx: (position)->
            xScale = (@_width - 2 * @_margin) / @_columns
            yScale = @_rowHeight

            result        = new ElementPosition
            result.x      = position.x * xScale + @_margin
            result.y      = position.y * yScale + @_margin
            result.width  = position.width * xScale - 2 * @_margin
            result.height = position.height * yScale - 2 * @_margin

            return result

        _findGridElements: ($parentEl)->
            results = []
            for childEl in $parentEl.find('.grid').children()
                results.push $(childEl)
            return results

        _initializeElements: ($elements)->
            @_elements = []
            for $element in $elements
                element =
                    $el: $element
                    cell: new ElementPosition
                    isDragging: false
                    px: new ElementPosition
                @_elements.push element

                element.cell.x      = $element.attr 'data-x'
                element.cell.y      = $element.attr 'data-y'
                element.cell.width  = $element.attr 'data-width'
                element.cell.height = $element.attr 'data-height'

        _refreshPxFromCellPositions: ->
            return unless @_elements.length > 0

            for element in @_elements
                element.px = @_convertCellToPx element.cell

        _refreshDomFromPxPositions: ->
            return unless @_elements.length > 0

            offset =
                x: @_$parentEl.offset().left + @_margin
                y: @_$parentEl.offset().top + @_margin

            for element in @_elements
                element.$el.offset left:element.px.x + offset.x, top:element.px.y + offset.y
                element.$el.height element.px.height
                element.$el.width element.px.width

        _refreshPxPositionFromDom: (element)->
            elementOffset     = element.$el.offset()
            element.px.x      = elementOffset.left
            element.px.y      = elementOffset.top
            element.px.width  = element.$el.width()
            element.px.height = element.$el.height()
