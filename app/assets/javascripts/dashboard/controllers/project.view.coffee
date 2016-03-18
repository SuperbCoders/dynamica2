class ProjectViewController
  constructor: (@rootScope, @scope, @Projects) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.project = {}

    @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
      vm.project = project
    )

    console.log 'ProjectViewController'

@application.controller 'ProjectViewController', ['$rootScope', '$scope', 'Projects', ProjectViewController]

