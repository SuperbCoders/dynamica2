class ProjectsController
  constructor: (@rootScope, @scope, @Projects) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.project = {}
    vm.projects = []


    if vm.params.slug
      @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
        vm.project = project
      )
    else
      @Projects.query().$promise.then( (projects) ->
        vm.projects = projects

        if vm.projects.length == 1
          vm.rootScope.$state.go('projects.view', {slug: vm.projects[0].slug})
      )

  # Open projects dropdown setting menu
  open_setting_menu: (project) ->
    $('.setting.open').removeClass('open')
    $("#setting_menu_#{project.id}").toggleClass('open')
    return

  # Destroy project
  destroy: (project) ->
    vm = @
    project.$remove({id: project.id}).then( (response) ->
      vm.projects.splice(vm.projects.indexOf(project), 1)
    )

  # Save & Create project
  save: ->
    vm = @
    if vm.project.id
      console.log "Save project #{vm.project.name}"
      vm.project.$save({id: vm.project.id}, (project, response) ->
        vm.view_project(project) if project.id and project.valid
      )
    else
      console.log "Create project"
      vm.Projects.create({project: vm.project}).$promise.then( (project) ->
        vm.view_project(project) if project.id and project.valid
      )

  # Go to project view
  view_project: (project) -> @rootScope.$state.go('projects.view', {slug: project.slug})

@application.controller 'ProjectsController', ['$rootScope', '$scope', 'Projects', ProjectsController]

