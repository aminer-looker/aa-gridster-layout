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
            @_ignoring = []
            @_margin = 5
            @_parentEl = $parentEl
            @_rowHeight = 100 # px
            @_width = $parentEl.width()

            @_initializeElements @_findGridElements $parentEl

        # Public Methods ###############################################################

        layoutElements: ->
            for element in @_elements
                continue if element in @_ignoring
                @_refreshPxFromCell element
                @_refreshDomFromPx element

        startIgnoring: ($el)->
            for element in @_elements
                if element.$el is $el
                    @_ignoring.push element
                    break

        stopIgnoring: ($el)->
            for element, index in @_ignoring
                if element.$el is $el
                    @_ignoring.splice index, 1
                    break

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

            elements:
                get: ->
                    return @_elements[..]

            parentEl:
                get: ->
                    return @_parentEl

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

        _refreshPxFromCell: (element)->
            xScale = (@_width - 2 * @_margin) / @_columns
            yScale = @_rowHeight

            element.px.x      = element.cell.x * xScale + @_margin
            element.px.y      = element.cell.y * yScale + @_margin
            element.px.width  = element.cell.width * xScale - 2 * @_margin
            element.px.height = element.cell.height * yScale - 2 * @_margin

        _refreshDomFromPx: (element)->
            offset =
                x: @_parentEl.offset().left + @_margin
                y: @_parentEl.offset().top + @_margin

            element.$el.offset left:element.px.x + offset.x, top:element.px.y + offset.y
            element.$el.height element.px.height
            element.$el.width element.px.width

        _refreshPxFromDom: (element)->
            elementOffset     = element.$el.offset()
            element.px.x      = elementOffset.left
            element.px.y      = elementOffset.top
            element.px.width  = element.$el.width()
            element.px.height = element.$el.height()
