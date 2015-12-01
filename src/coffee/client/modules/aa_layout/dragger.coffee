#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'Dragger', class Dragger

    constructor: ($draggableEls)->
        @_addMouseHandlers $draggableEls

        @_isDragging = false
        @_dragStartOffset = {top:0, left:0}

    # Private Methods ##################################################################

    _addMouseHandlers: ->
        for $el in $draggableEls
            do ($el)->
                $el.mouseDown (event)=> @_onMouseDown $el, event
                $el.mouseMove (event)=> @_onMouseMove $el, event
                $el.mouseUp   (event)=> @_onMouseUp   $el, event

    _onMouseDown: ($el, event)->

    _onMouseMove: ($el, event)->

    _onMouseUp: ($el, event)->
