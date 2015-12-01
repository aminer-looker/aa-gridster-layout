#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'ElementPosition', class ElementPosition

    init: ->
        @x = 0
        @y = 0
        @width = 0
        @height = 0
