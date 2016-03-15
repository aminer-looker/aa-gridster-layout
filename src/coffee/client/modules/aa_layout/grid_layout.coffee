#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../../underscore'
angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'GridLayout', (ElementPosition, PushAttempt)->

    class GridLayout

        constructor: ($parentEl)->
            @_columns     = 12
            @_elements    = []
            @_ignoring    = []
            @_margin      = 5 # px
            @_parentEl    = $parentEl
            @_reserved    = null
            @_placeholder = $parentEl.find '.reserved'
            @_rowHeight   = 100 # px
            @_width       = $parentEl.width()

            @_initializeElements @_findGridElements $parentEl

        # Public Methods ###############################################################

        layoutElements: ->
            @_slideElementsUp()

            for element in @_elements
                continue if element in @_ignoring

                @_refreshPxFromCell element
                @_refreshDomFromPx element
                element.slid = null

            @_updateParentHeight()

        claimReservedSpace: ($el)->
            @_placeholder.removeClass 'visible'

            for element in @_elements
                if element.$el[0] is $el[0]
                    element.cell = @_reserved.cell
                else if element.pushed?
                    element.cell = element.pushed
                    element.pushed = null

            @_reserved = null

        reserveSpace: ($el)->
            @_reserved =
                $el:  $el
                cell: new ElementPosition
                px:   new ElementPosition

            Object.defineProperty @_reserved, 'effectiveCell', get:-> @cell

            @_refreshPxFromDom @_reserved
            @_refreshCellFromPx @_reserved
            @_refreshPxFromCell @_reserved

            offset =
                x: @_parentEl.offset().left + @_margin
                y: @_parentEl.offset().top + @_margin

            @_placeholder.offset top:@_reserved.px.y + offset.y, left:@_reserved.px.x + offset.x
            @_placeholder.width @_reserved.px.width
            @_placeholder.height @_reserved.px.height
            @_placeholder.addClass 'visible'

            @_resetPushedPositions()
            @_pushElementsFromReservedSpace()
            @layoutElements()

        startIgnoring: ($el)->
            @_ignoring = []
            for element in @_elements
                if element.$el[0] is $el[0]
                    @_ignoring.push element
                    break

        stopIgnoring: ($el)->
            for element, index in @_ignoring
                if element.$el[0] is $el[0]
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

        _attemptPush: (element, toAvoid, onSide)->
            elementPosition = element.pushed or element.cell
            attempt = new PushAttempt element, elementPosition.nextTo(toAvoid, onSide)

            if attempt.to.x    < 0         then return attempt.fail()
            if attempt.to.maxX > @_columns then return attempt.fail()
            if attempt.to.y    < 0         then return attempt.fail()

            overlappingElements = @_findOverlappingElements attempt.to, element
            for child in overlappingElements
                childAttempt = @_attemptPush child, attempt.to, onSide
                if childAttempt.successful
                    attempt.children.push childAttempt
                else
                    return attempt.fail()

            return attempt

        _resetPushedPositions: ->
            for element in @_elements
                element.pushed = null

        _findGridElements: ($parentEl)->
            results = []
            for childEl in $parentEl.find('.grid').children()
                results.push $(childEl)
            return results

        _findOverlappingElements: (position, except=null)->
            result = []
            for element in @_elements
                continue if element is except
                continue if element in @_ignoring

                elementPosition = element.effectiveCell
                if position.overlaps elementPosition
                    result.push element

            return result

        _initializeElements: ($elements)->
            @_elements = []
            for $element in $elements
                element =
                    id:         _.uniqueId 'grid-'
                    $el:        $element
                    cell:       new ElementPosition
                    isDragging: false
                    px:         new ElementPosition
                    pushed:     null
                    slid:       null
                    toString:   -> @id

                Object.defineProperty element, 'effectiveCell', get:->
                    return @slid or @pushed or @cell

                @_elements.push element
                @_refreshCellFromDom element

        _doesOverlapReserved: (position)->
            return false unless @_reserved
            return false unless position
            return position.overlaps @_reserved.cell

        _pushElementsFromReservedSpace: ->
            for element in @_elements
                elementPosition = element.effectiveCell
                continue unless @_doesOverlapReserved elementPosition
                continue if element in @_ignoring

                attempt = @_attemptPush element, @_reserved.cell, 'top'
                if not attempt.successful
                    attempt = @_attemptPush element, @_reserved.cell, 'left'
                if not attempt.successful
                    attempt = @_attemptPush element, @_reserved.cell, 'right'
                if not attempt.successful
                    attempt = @_attemptPush element, @_reserved.cell, 'bottom'

                if attempt.successful
                    attempt.commit()

        _refreshCellFromDom: (element)->
            element.cell.x      = parseInt element.$el.attr 'data-x'
            element.cell.y      = parseInt element.$el.attr 'data-y'
            element.cell.width  = parseInt element.$el.attr 'data-width'
            element.cell.height = parseInt element.$el.attr 'data-height'

        _refreshCellFromPx: (element)->
            xScale = ((@_width - 2 * @_margin) / @_columns)
            yScale = @_rowHeight

            element.cell.x      = Math.round (element.px.x - @_parentEl.offset().left) / xScale
            element.cell.y      = Math.round (element.px.y - @_parentEl.offset().top) / yScale
            element.cell.width  = Math.max 1, Math.round element.px.width / (xScale - @_margin)
            element.cell.height = Math.max 1, Math.round element.px.height / (yScale - @_margin)

        _refreshDomFromPx: (element)->
            offset =
                x: @_parentEl.offset().left + @_margin
                y: @_parentEl.offset().top + @_margin

            element.$el.offset left:element.px.x + offset.x, top:element.px.y + offset.y
            element.$el.height element.px.height
            element.$el.width element.px.width

        _refreshPxFromCell: (element)->
            xScale = ((@_width - @_margin) / @_columns)
            yScale = @_rowHeight

            cell = element.effectiveCell

            element.px.x      = cell.x * xScale
            element.px.y      = cell.y * yScale
            element.px.width  = cell.width * xScale - @_margin
            element.px.height = cell.height * yScale - @_margin

        _refreshPxFromDom: (element)->
            elementOffset     = element.$el.offset()
            element.px.x      = elementOffset.left
            element.px.y      = elementOffset.top
            element.px.width  = element.$el.width()
            element.px.height = element.$el.height()

        _slideElementsUp: ->
            sortedElements = @_elements[..]
            sortedElements.sort (a, b)->
                if a.cell.y isnt b.cell.y
                    return if a.cell.y < b.cell.y then -1 else +1
                if a.cell.x isnt b.cell.x
                    return if a.cell.x < b.cell.x then -1 else +1
                return 0

            for element in sortedElements
                continue if element in @_ignoring
                continue if element.effectiveCell.y is 0

                position        = element.effectiveCell.clone()
                lastAcceptableY = position.y
                while true
                    position.y -= 1
                    overlapsReserved = @_doesOverlapReserved position
                    overlappedElements = @_findOverlappingElements position, element
                    overlapping = overlapsReserved or overlappedElements.length > 0

                    if not overlapping
                        lastAcceptableY = position.y

                    if overlapping or position.y is 0
                        position.y = lastAcceptableY
                        element.slid = position
                        break

        _updateParentHeight: ->
            maxY = 0
            if @_reserved? then maxY = @_reserved.px.y + @_reserved.px.height

            for element in @_elements
                maxY = Math.max maxY, element.px.y + element.px.height

            @_parentEl.height maxY + 2 * @_margin
