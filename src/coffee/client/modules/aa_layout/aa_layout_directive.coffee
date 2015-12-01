#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

initializeElements = ($parentEl)->
  # TODO: read existing DOM elements and get the x, y, height, width off of them

layoutElements = ($parentEl, positionList)->
  # TODO: set the CSS positioning & size of each of these to the correct X/Y coordinates

angular.module('aa-layout').directive 'aaLayout', ->
  bindToController: true
  controller: 'AALayoutController'
  controllerAs: 'layoutController'
  link: (scope, $el, attrs, controller)->
    controller.layoutElements = (positionList)-> layoutElements($el, positionList)
    controller.refresh()
  restrict: 'E'
  scope: {
    columns: '@'
    rowHeight: '@'
  }
  template: templates['aa-layout']
  transclude: true
