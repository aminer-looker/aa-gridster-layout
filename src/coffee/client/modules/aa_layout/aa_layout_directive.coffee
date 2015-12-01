#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

angular.module('aa-layout').directive 'aaLayout', (GridLayout)->
  controller: 'AALayoutController'
  controllerAs: 'layoutController'
  link: (scope, $el, attrs, controller)->
      layout = new GridLayout $el
      layout.columns = scope.columns
      layout.rowHeight = scope.rowHeight
      layout.layoutElements()

  restrict: 'E'
  scope: {
    columns: '@'
    rowHeight: '@'
  }
  template: templates['aa-layout']
  transclude: true
