class ChartController
  constructor: (@rootScope, @scope, @Projects) ->
    vm = @
    vm.slug = @rootScope.$stateParams.slug
    vm.chart_type = @rootScope.$stateParams.chart
    vm.project = @rootScope.$stateParams.project

    if not @project
      @Projects.search({slug: vm.slug}).$promise.then( (project) ->
        vm.project = project
      )



@application.controller 'ChartController', ['$rootScope', '$scope', 'Projects', ChartController]
