#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular   = require 'angular'
templates = require '../../templates'

############################################################################################################

angular.module('aa-layout').directive 'aaLayout', ->
  controller: 'AALayoutController'
  controllerAs: 'layoutController'
  restrict: 'E'
  scope: {}
  template: templates['aa-layout']
  transclude: true
