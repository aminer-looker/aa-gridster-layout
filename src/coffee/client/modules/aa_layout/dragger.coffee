#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_       = require '../../../underscore'
angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'Dragger', ($timeout)->

    class Dragger

        constructor: (layout, $grid)->
            @_draggedElement  = null
            @_dragStartOffset = x:0, y:0
            @_dragStartSize   = height:0; width: 0
            @_$grid           = $grid
            @_isDragging      = false
            @_layout          = layout
            @_pendingCancel   = null

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

        _onMouseMove: (event)->
            return unless @_draggedElement?
            event.preventDefault()
            $el = @_draggedElement

            if @_dragMode is 'move'
                maxLeft = @_$grid.offset().left + @_$grid.width() - $el.width()

                top = Math.max 0, event.pageY - @_dragStartOffset.y
                left = Math.min maxLeft, Math.max 0, event.pageX - @_dragStartOffset.x

                $el.offset top:top, left:left
            else if @_dragMode is 'resize'
                height = @_dragStartSize.height + (event.pageY - $el.offset().top) - @_dragStartOffset.y
                width = @_dragStartSize.width + (event.pageX - $el.offset().left) - @_dragStartOffset.x
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

            @_layout.claimReservedSpace $el
            @_layout.stopIgnoring $el
            @_layout.layoutElements()
