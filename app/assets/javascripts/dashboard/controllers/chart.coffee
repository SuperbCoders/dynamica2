class ChartController
  constructor: (@rootScope, @scope, @Projects) ->
    vm = @
    console.log @rootScope.$stateParams.project
    console.log 'chart controller loaded'

@application.controller 'ChartController', ['$rootScope', '$scope', 'Projects', ChartController]
