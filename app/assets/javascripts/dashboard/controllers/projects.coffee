class ProjectsController
  constructor: (@rootScope, @scope, @Projects) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.project = {}
    vm.projects = [{id: null}]

    if vm.params.slug
      @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
        vm.project = project
      )
    else
      @Projects.query().$promise.then( (projects) ->
        vm.projects = projects
      )

  modal: (name, action) ->
    # Close all modals
    $('.modal').modal('hide')

    # Open modal
    $('#'+name).modal(action, {backdrop: 'static'})
    return

  open_setting_menu: (project) ->
    $('.setting.open').removeClass('open')
    $("#setting_menu_#{project.id}").toggleClass('open')
    return

  destroy: (project) ->
    vm = @
    project.$remove({id: project.id}).then( (response) ->
      vm.projects.splice(vm.projects.indexOf(project), 1)

      vm.rootScope.update_user()
    )

  save: ->
    vm = @
    if vm.project.id
      vm.project.$save({id: vm.project.id}, (project, response) ->
        vm.view_project(project) if project.id and project.valid
      )
    else
      vm.Projects.create({project: vm.project}).$promise.then( (project) ->
        vm.view_project(project) if project.id and project.valid
      )

  view_project: (project) -> @rootScope.$state.go('projects.view', {slug: project.slug})

@application.controller 'ProjectsController', ['$rootScope', '$scope', 'Projects', ProjectsController]

