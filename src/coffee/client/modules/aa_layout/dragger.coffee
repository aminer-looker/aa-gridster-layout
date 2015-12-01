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
            @_dragStartOffset = {x:0, y:0}
            @_draggedElement  = null
            @_layout          = layout

            @_addMouseHandlers (element.$el for element in layout.elements)

        # Private Methods ##############################################################

        _addMouseHandlers: ($draggableEls)->
            for $el in $draggableEls
                do ($el)=>
                    $el.mousedown (event)=> @_onMouseDown $el, event
                    $el.mousemove (event)=> @_onMouseMove $el, event
                    $el.mouseup   (event)=> @_onMouseUp   $el, event

        _onMouseDown: ($el, event)->
            @_isDragging = true
            event.preventDefault()

            @_dragStartOffset =
                x: event.pageX - $el.offset().left
                y: event.pageY - $el.offset().top

            @_draggedElement = $el
            @_draggedElement.addClass 'dragging'

            @_layout.startIgnoring $el
            @_layout.reserveSpace $el

        _onMouseMove: ($el, event)->
            return unless $el is @_draggedElement
            event.preventDefault()

            $el.offset top:event.pageY - @_dragStartOffset.y, left:event.pageX - @_dragStartOffset.x
            @_layout.layoutElements()
            @_layout.reserveSpace $el

        _onMouseUp: ($el, event)->
            return unless $el is @_draggedElement
            event.preventDefault()

            $el.removeClass 'dragging'
            $el.addClass 'drag-ending'
            $timeout (=> $el.removeClass 'drag-ending'), 300

            @_isDragging      = false
            @_dragStartOffset = null
            @_draggedElement  = null

            @_layout.stopIgnoring $el
            @_layout.clearReservedSpace()
            @_layout.layoutElements()
