#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'Dragger', ($timeout)->

    class Dragger

        constructor: (layout)->
            @_isDragging      = false
            @_dragStartOffset = x:0, y:0
            @_dragStartSize   = height:0; width: 0
            @_draggedElement  = null
            @_layout          = layout
            @_pendingCancel   = null

            @_addMouseHandlers (element.$el for element in layout.elements)

        # Private Methods ##############################################################

        _determineDragMode: ($el, event)->
            $element = $(event.target)

            while $element.length > 0
                if $element.hasClass 'move-handle'
                    return 'move'
                else if $element.hasClass 'resize-handle'
                    return 'resize'

                $element = $element.parent()

            return null

        _addMouseHandlers: ($draggableEls)->
            for $el in $draggableEls
                do ($el)=>
                    $el.mousedown (event)=> @_onMouseDown $el, event
                    $el.mousemove (event)=> @_onMouseMove $el, event
                    $el.mouseup   (event)=> @_onMouseUp   $el, event
                    $el.mouseout  (event)=> @_onMouseOut  $el, event

        _onMouseDown: ($el, event)->
            dragMode = @_determineDragMode $el, event
            return unless dragMode?

            @_dragMode = dragMode
            @_isDragging = true
            event.preventDefault()

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

        _onMouseMove: ($el, event)->
            return unless $el is @_draggedElement
            event.preventDefault()

            if @_dragMode is 'move'
                $el.offset top:event.pageY - @_dragStartOffset.y, left:event.pageX - @_dragStartOffset.x
            else if @_dragMode is 'resize'
                height = @_dragStartSize.height + (event.pageY - $el.offset().top) - @_dragStartOffset.y
                width = @_dragStartSize.width + (event.pageX - $el.offset().left) - @_dragStartOffset.x
                $el.css height:height, width: width

            @_layout.reserveSpace $el

        _onMouseOut: ($el, event)->
            @_onMouseMove $el, event

        _onMouseUp: ($el, event)->
            return unless $el is @_draggedElement
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
