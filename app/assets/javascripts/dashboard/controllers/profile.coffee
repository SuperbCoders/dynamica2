class ProfileController
  constructor: (@rootScope, @http) ->
    vm = @
    vm.password =
      new_password: false
      password_confirmation: false
      current_password: false

    console.log 'ProfileController'

  save: ->
    vm = @
    vm.http.post('/profile', @rootScope.user).then((response) ->
      vm.password = response.data.password

      if response.data.profile.valid
        vm.rootScope.user = response.data.profile
    )

@application.controller 'ProfileController', ['$rootScope', '$http', ProfileController]


