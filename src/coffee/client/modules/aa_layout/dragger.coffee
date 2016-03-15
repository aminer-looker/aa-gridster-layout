#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../../underscore'
angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'Dragger', ($timeout)->

    class Dragger

        constructor: (layout, $grid, $scrollContainer)->
            @_$grid               = $grid
            @_$scrollContainer    = $scrollContainer
            @_autoscrollId        = null
            @_autoscrollFrameRate = 30
            @_draggedElement      = null
            @_dragStartOffset     = x:0, y:0
            @_dragStartSize       = height:0; width: 0
            @_isDragging          = false
            @_layout              = layout
            @_maxScrollDelta      = 5 # px
            @_pendingCancel       = null
            @_repeatEvent         = null
            @_scrollBuffer        = 20 # px

            @_addMouseHandlers()

        # Private Methods ##############################################################

        _determineDragMode: (event)->
            $element = $(event.target)

            while $element.length > 0
                if $element.hasClass 'move-handle'
                    return 'move'
                else if $element.hasClass 'resize-handle'
                    return 'resize'

                $element = $element.parent()

            return null

        _determineGridElement: (event)->
            $element = $(event.target)

            $candidate = null
            while $element.length > 0
                if $element.hasClass 'grid-element'
                    $candidate = $element
                if $candidate? and $element[0] is @_$grid[0]
                    return $candidate

                $element = $element.parent()

            return null

        _addMouseHandlers: ->
            document.addEventListener 'mousedown', (event)=> @_onMouseDown event
            document.addEventListener 'mousemove', (event)=> @_onMouseMove event
            document.addEventListener 'mouseout',  (event)=> @_onMouseOut  event
            document.addEventListener 'mouseup',   (event)=> @_onMouseUp event

        _onMouseDown: (event)->
            $el = @_determineGridElement event
            dragMode = @_determineDragMode event
            return unless $el? and dragMode?
            event.preventDefault()

            @_dragMode = dragMode
            @_isDragging = true

            @_dragStartOffset =
                x: event.pageX - $el.offset().left
                y: event.pageY - $el.offset().top
            @_dragStartSize =
                height: $el.height()
                width: $el.width()

            @_draggedElement = $el
            @_draggedElement.addClass 'dragging'

            @_layout.startIgnoring $el
            @_layout.reserveSpace $el

            @_updateScrollPosition(event)

        _onMouseMove: (event)->
            return unless @_draggedElement?
            event.preventDefault()
            $el = @_draggedElement

            @_updateScrollPosition(event)

            if @_dragMode is 'move'
                minLeft = @_$grid.offset().left
                maxLeft = @_$grid.offset().left + @_$grid.width() - $el.width()

                top = Math.max @_$grid.offset().top, event.pageY - @_dragStartOffset.y
                left = Math.min maxLeft, Math.max minLeft, event.pageX - @_dragStartOffset.x

                $el.offset top:top, left:left
            else if @_dragMode is 'resize'
                height = @_dragStartSize.height + (event.pageY - $el.offset().top) - @_dragStartOffset.y
                width = @_dragStartSize.width + (event.pageX - $el.offset().left) - @_dragStartOffset.x
                width = Math.min width, @_$grid.offset().left + @_$grid.width() - $el.offset().left
                $el.css height:height, width: width

            @_layout.reserveSpace $el

        _onMouseOut: (event)->
            @_onMouseMove event

        _onMouseUp: (event)->
            $el = @_determineGridElement event
            return unless $el? and @_draggedElement?
            event.preventDefault()

            $el.removeClass 'dragging'
            $el.addClass 'drag-ending'
            $timeout (=> $el.removeClass 'drag-ending'), 300

            @_isDragging      = false
            @_dragStartOffset = null
            @_dragStartSize   = null
            @_draggedElement  = null
            @_stopAutoscroll()

            @_layout.claimReservedSpace $el
            @_layout.stopIgnoring $el
            @_layout.layoutElements()

            # layout again after CSS animations have completed since scrollbars may have been added/removed
            # during the transitions
            _.delay (=> @_layout.layoutElements()), 100

        _startAutoscroll: (event)->
            @_stopAutoscroll()
            @_autoscrollId = setTimeout (=> @_onMouseMove event), (1000 / @_autoscrollFrameRate)

        _stopAutoscroll: ->
            return unless @_autoscrollId
            clearTimeout @_autoscrollId

        _updateScrollPosition: (event)->
            return unless @_$scrollContainer
            scroller = @_$scrollContainer

            @_stopAutoscroll()
            if event.pageY < scroller.offset().top + @_scrollBuffer
                scrollDelta = 2 * scroller.offset().top + @_scrollBuffer - event.pageY
                scrollDelta = Math.min @_maxScrollDelta, scrollDelta
                scroller.scrollTop scroller.scrollTop() - scrollDelta
                @_startAutoscroll(event)

            if event.pageY > scroller.offset().top + scroller.height() - @_scrollBuffer
                scrollDelta = @_scrollBuffer - (scroller.offset().top + scroller.height() - event.pageY)
                scrollDelta = Math.min @_maxScrollDelta, scrollDelta
                scroller.scrollTop scroller.scrollTop() + scrollDelta
                @_startAutoscroll(event)
