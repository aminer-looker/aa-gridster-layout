#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

_         = require '../../../underscore'
angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

angular.module('aa-layout').directive 'aaLayout', (Dragger, GridLayout)->
  controller: 'AALayoutController'
  controllerAs: 'layoutController'
  link: (scope, $el, attrs, controller)->
      layout = new GridLayout $el
      layout.columns = scope.columns
      layout.rowHeight = scope.rowHeight
      layout.layoutElements()

      $(window).on 'resize', _.throttle (-> layout.layoutElements()), 25

      dragger = new Dragger layout, $el, $('.scroll-container')

  restrict: 'E'
  scope: {
    columns: '@'
    rowHeight: '@'
  }
  template: templates['aa-layout']
  transclude: true
