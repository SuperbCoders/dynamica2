class ChartController
  constructor: (@rootScope, @scope, @Projects) ->
    vm = @
    console.log 'chart controller loaded'

@application.controller 'ChartController', ['$rootScope', '$scope', 'Projects', ChartController]
