class ProfileController
  constructor: (@rootScope, @scope, @http, @Routes, @window) ->
    vm = @
    vm.subscription = {sub_type: @rootScope.user.subscription.sub_type}
    vm.password =
      new_password: false
      password_confirmation: false
      current_password: false

    $('.project-select2').select2();

    if @rootScope.user.projects.length == 1
      vm.subscription.project_id = @rootScope.user.projects[0].id

    if @rootScope.user.subscription.expired
      $('.modal').modal('hide')
      $('#subscription_expired').modal('show', {backdrop: 'static'})

      if @rootScope.user.projects.length == 1
        vm.subscription.project = @rootScope.user.projects[0]

    @scope.$watch('vm.subscription.project', (project) ->
      vm.subscription.project_id = project.id if project and project.id
    )

    @scope.FILE_TYPES = { VALID: 1, INVALID: 2, DELETED: 4, UPLOADED: 8 }
    @scope.$on('$dropletReady', ->
      vm.avatar.allowedExtensions(['png', 'jpg', 'bmp', 'gif'])
      vm.avatar.setRequestUrl(vm.Routes.upload_avatar_path())
      vm.avatar.defineHTTPSuccess([/2.{2}/])
      vm.avatar.useArray(false)
      vm.avatar.setRequestHeaders({'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')})
    )

    @scope.$on('$dropletSuccess', (event, user) ->
      vm.rootScope.user = user
    )

    @scope.$on('$dropletFileAdded', (event, file) ->
      vm.avatar.uploadFiles()
    )

  # Show subscription logs
  show_subscription_logs: ->
    $('.modal').modal('hide')
    $('#subscription_logs').modal('show', {backdrop: 'static'})

  # Show cancel subscription
  show_cancel_subscription: ->
    $('.modal').modal('hide')
    $('#cancel_subscription').modal('show', {backdrop: 'static'})

  # Change subscription type
  change_subscription: (type) ->
    user = @rootScope.user
    vm = @
    console.log 'Change subscription to '+type

    # Show error if user do not select shopify shop for process payment
    if user.projects.length > 1 and not vm.subscription.project_id
      return @rootScope.alerts.success('You should select ')
    else if user.projects.length == 1
      vm.subscription.project_id = user.projects[0].id

    # Show error if subscription type not selected
    if not vm.subscription.sub_type or vm.subscription.sub_type is 'trial'
      return @rootScope.alerts.error('You should select subscription type')

    vm.requested = true
    vm.http.post(vm.Routes.change_subscription_path(), vm.subscription).then((response) ->
      data = response.data

      if data.success
        vm.window.location.href = response.data.charge.confirmation_url
      else
        console.log data
        vm.requested = false
    )


  # Destroy user avatar
  destroy_avatar: ->
    vm = @

    $("#avatar_input").val('')

    vm.http.post(vm.Routes.destroy_avatar_path(), {}).then((response) ->
      vm.rootScope.user = response.data
    )

  # Save profile
  save: ->
    vm = @
    vm.http.post(vm.Routes.update_profile_path(), @rootScope.user).then((response) ->
      vm.password = response.data.password

      if response.data.profile.valid
        vm.rootScope.user = response.data.profile
    )

@application.controller 'ProfileController', ['$rootScope', '$scope', '$http', 'Routes', '$window', ProfileController]


