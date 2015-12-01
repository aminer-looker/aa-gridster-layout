#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

# Allow Node.js-style `global` in addition to `window`
if typeof(global) is 'undefined'
    window.global = window

# Add 'require' statements for your other Angular module files here.
require './modules/aa_layout/aa_layout_module'

# Add all your modules here.
MODULES = [
    'aa-layout'
]

angular.module 'app', MODULES
    .config ($locationProvider)->
        $locationProvider.html5Mode true

console.log "client is ready"
