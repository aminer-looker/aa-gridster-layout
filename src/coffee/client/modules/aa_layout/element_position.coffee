#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'ElementPosition', ->

    class ElementPosition

        constructor: (@x=0, @y=0, @width=0, @height=0)-> # do nothing

        # Public Methods ###############################################################

        clone: ->
            return new ElementPosition @x, @y, @width, @height

        nextTo: (position, side)->
            result = null

            if side is 'bottom'
                result = @clone()
                result.y = position.y + position.height
            if side is 'left'
                result = @clone()
                result.x = position.x - @width
            else if side is 'right'
                result = @clone()
                result.x = position.x + position.width
            else if side is 'top'
                result = @clone()
                result.y = position.y - @height
            else
                throw new Error "Invalid direction: #{inDirection}"

            return result

        overlaps: (that)->
            maxStartX = Math.max this.x, that.x
            maxStartY = Math.max this.y, that.y
            minEndX   = Math.min this.x + this.width, that.x + that.width
            minEndY   = Math.min this.y + this.height, that.y + that.height

            return (maxStartX > minEndX) and (maxStartY > minEndY)

        # Property Methods #############################################################

        Object.defineProperties @prototype,
            maxX:
                get: -> @x + @width

            maxY:
                get: -> @y + @height
