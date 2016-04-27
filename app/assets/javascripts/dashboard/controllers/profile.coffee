class ProfileController
  constructor: (@rootScope, @scope, @http, @Routes) ->
    vm = @
    vm.password =
      new_password: false
      password_confirmation: false
      current_password: false

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

  destroy_avatar: ->
    vm = @

    $("#avatar_input").val('')

    vm.http.post(vm.Routes.destroy_avatar_path(), {}).then((response) ->
      vm.rootScope.user = response.data
    )

  save: ->
    vm = @
    vm.http.post(vm.Routes.update_profile_path(), @rootScope.user).then((response) ->
      vm.password = response.data.password

      if response.data.profile.valid
        vm.rootScope.user = response.data.profile
    )

@application.controller 'ProfileController', ['$rootScope', '$scope', '$http', 'Routes', ProfileController]


