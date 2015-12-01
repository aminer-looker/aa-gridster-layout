#
# Copyright (C) 2015 by Looker Data Services, Inc.
# All rights reserved.
#

angular = require 'angular'

############################################################################################################

angular.module('aa-layout').factory 'PushAttempt', ->

    class PushAttempt

        constructor: (element, to)->
            @element    = element
            @to         = to
            @children   = []
            @successful = true

        # Public Methods ###############################################################

        commit: ->
            if not @successful then throw new Error 'cannot commit an unsuccessful attempt'

            @element.pushed = @to
            for child in @children
                child.commit()

            return this

        fail: ->
            @successful = false
            @children = []
            return this
