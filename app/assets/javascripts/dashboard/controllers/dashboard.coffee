class DashboardController
  constructor: (@rootScope, @scope, @Projects, @Charts) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.project = {}

    $('.selectpicker').selectpicker({size: 7, showTick: false, showIcon: false})
    $('.page').addClass('dashboard_page')

    @scope.$on('$destroy', ->
      $('.page').removeClass('dashboard_page')
    )
    @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
      vm.project = project
      vm.Charts.set_project(vm.project)
      vm.Charts.full_chart_data()
    )

    console.log 'DashboardController'

@application.controller 'DashboardController', ['$rootScope', '$scope', 'Projects', 'Charts', DashboardController]

